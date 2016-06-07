% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [CM, ST, RMSE, mirrored] = main(orthophoto, gcp, varargin)
%% Discription
% MAIN is the main entery point for extracting ground controll points in
% the given ortophoto, and then georeference the image and rectify it.

%% Parse input

i_p = inputParser;
i_p.FunctionName = 'MAIN';

% Requiered
i_p.addRequired('orthophoto', @is_image_or_path);
i_p.addRequired('gcp', @is_point_list_or_path);

% Optional:
%Digital elevation model
i_p.addParameter('DigitalElevationModel', false, @is_dem_or_disabled);
i_p.addParameter('ElevationModel', false, @is_dem_or_disabled);
i_p.addParameter('DEM', false, @is_dem_or_disabled);

% Sample of ground control points
i_p.addParameter('GCPSample', '../../data/gcp_vals.mat', @is_sample_data_or_disabled);

% Area of a single ground control point in pixles.
i_p.addParameter('GCPArea', 9, @is_positive_integer);

% The maximum allowed root mean square error before mirroring the
% coordinates.
i_p.addParameter('MaxRMSE', 10^5, @is_positive_number);

% The distance function to be used.
i_p.addParameter('DistanceFunction', false, @is_function_or_logical);

% Max normalized distance. Used as a upper threshold.
i_p.addParameter('MaxDistance', 0.01, @is_number);

% Fraction of ground control points that need to match on the first run
i_p.addParameter('FractionMatched', 1/3, @is_fraction);

% Write world file
% Writes the wf iff the orthophoto was given by path.
i_p.addParameter('WriteWorldFile', true, @islogical);

% Rematch all points
i_p.addParameter('Rematch', true, @islogical);
% Which algorithm is to be used to find the absolute orientation?
i_p.addParameter('OrientationAlgorithm', 'Horn', @is_valid_orientation_algorithm);

i_p.addParameter('MinimumMatches', 5, @is_number);
i_p.addParameter('RadiusThreshold', 0.05, @is_number);
i_p.addParameter('AngleThreshold', 0.05, @is_number);

i_p.addParameter('UseProbability', true, @islogical);

i_p.addParameter('UseHornScale', false, @islogical);

i_p.parse(orthophoto, gcp, varargin{:});

%% Deal with the input
input = i_p.Results;

% Required
orthophoto      = input.orthophoto;
gcp             = input.gcp;

% Optional
dem             = get_dem(input);
gcp_sample      = input.GCPSample;
gcp_area        = input.GCPArea;
max_rmse        = input.MaxRMSE;
distance_fun    = input.DistanceFunction;
max_distamce    = input.MaxDistance;
min_fraction    = input.FractionMatched;
rematch         = input.Rematch;
use_probability = input.UseProbability;
absor_alg       = input.OrientationAlgorithm;
min_matches     = input.MinimumMatches;
rad_thresh      = input.RadiusThreshold;
ang_thresh      = input.AngleThreshold;
use_horn_scale  = input.UseHornScale;

%% Initializing

% Orthophoto
orthophoto_path = '';
if ischar(orthophoto)
    orthophoto_path = orthophoto;
    orthophoto = im2double(imread(orthophoto));
elseif ~isa(orthophoto, 'double')
    orthophoto = im2double(orthophoto);
end
if size(orthophoto, 3) == 4
    % Remove trasnparencey / used it to mask the image
    %TODO: Use the mask to limit the data.
    orthophoto = orthophoto(:,:,1:3);
end

% Ground control points
if ischar(gcp)
    [gcp, crc, names] = load_geojson(gcp);
elseif is_point_list(gcp)
    warning('No datum of the coordinates was given!');
end

% Digitial elevation model
if ischar(dem)
    dem = imread(dem);
end

% Sample data of ground control points
if ischar(gcp_sample)
    gcp_sample = open(gcp_sample);
    fn = fieldnames(gcp_sample);
    gcp_sample = gcp_sample.(fn{1});
end
gcp_sample_lab = rgb2lab(gcp_sample);

if ~isa(distance_fun, 'function_handle')
    % Mahalanobis distance
    distance_fun = @(x) mahal_dist(x, gcp_sample_lab);
end

mirrored = false;

%% Get ground control points and match them
[location, ~, ~] = find_signal_colors(orthophoto, gcp_sample, 'UseProbability', use_probability);

if dem
    heights = get_heights(dem, location, gcp_area);
    location = [location, heights];
end

min_matches = ceil(size(gcp, 1) * min_fraction);

[CM, ST, RMSE] = match_gcps(location, gcp, ...
    'GetOptimal', true, ...
    'ImageTPPMode', 'all', ...
    'MinimumMatches', min_matches, ...
    'OrientationAlgorithm', absor_alg, ...
    'UseHornScale', use_horn_scale, ...
    'AngleThreshold', ang_thresh, ...
    'RadiusThreshold' , rad_thresh);

%% Check if the points have to be mirrored
if RMSE > max_rmse
    location = mirror(location, 'Vertical');
    mirrored = true;
    % Alt. gcp = [gcp(:,2), gcp(:,1) gcp(:,3)];
    [CM, ST, RMSE] = match_gcps(location, gcp, ...
        'GetOptimal', true, ...
        'ImageTPPMode', 'all', ...
        'MinimumMatches', min_matches);
end

%% Find where all the ground control points are
if rematch
    [R_inv, t_inv, c_inv] = invert(ST);

    gcp_in_orthophoto = transform_points(gcp, R_inv, t_inv, c_inv);
    gcp_in_orthophoto = gcp_in_orthophoto(:,1:2);
    
    % Remove those that are outside of the image
    ortho_size = size(orthophoto);
    outside = gcp_in_orthophoto(:, 1) >  ortho_size(2) | ...
              gcp_in_orthophoto(:, 2) >  ortho_size(1) | ...
              gcp_in_orthophoto(:, 1) <= 0 | ...
              gcp_in_orthophoto(:, 2) <= 0;
    gcp_in_orthophoto(outside, :) = [];
    
    area = max([RMSE / 2, gcp_area * 4]);

    gcp_imgs = get_area(orthophoto, gcp_in_orthophoto, area);

    % Remove empty cells
    n_before = numel(gcp_imgs);
    gcp_imgs = remove_empty_cells(gcp_imgs);

    n_after = numel(gcp_imgs);

    if n_before ~= n_after
        warning('There are ground control points that falls outside the image. Consider increasing the minimum number of matched points.');
    end
    %% Get centres of each ground control point in images

    n = numel(gcp_imgs);
    image_coordinates = zeros(n, 2);
    for i = 1:n
        img = gcp_imgs{i};
        img = rgb2lab(img);
        distance_img = distance_fun(img);
        distance_img = normalize(distance_img);
        BW = distance_img <= max_distamce;
        image_coordinates(i, :) = get_centroid_of_largest_area( BW );
    end

    %% Calculate offsets
    centre_of_images = ceil(size(gcp_imgs{1}) / 2);
    centre_of_images = centre_of_images(1:2);

    offset = bsxfun(@minus, image_coordinates, centre_of_images);

    location = round(gcp_in_orthophoto + offset);

    %% Rematch all points
    if dem
        heights = get_heights(dem, location, gcp_area);
        location = [location, heights];
    end

    [CM, ST, RMSE] = match_gcps(location, gcp, ...
        'GetOptimal', true, ...
        'ImageTPPMode', 'all', 'MinimumMatches', size(location, 1));
end

if ~strcmp(orthophoto_path, '')
    C = strsplit(orthophoto_path, '.');
    ext = C{end};
    ext = strcat(ext(1), 'wf');
    path = cell((numel(C) - 1) * 2, 1);
    for i = 1:2:2*(numel(C) - 1)
        path{i} = C{i};
        path{i + 1} = '.';
    end
    path = strjoin(path, '');
    worldfile_path = strcat(path, ext);
    
    write_world_file(worldfile_path, ST);
end

end

%=========================================================================
%% ADDITIONAL FUNCTIONS
%=========================================================================

%% GET_DEM
%=========================================================================
function res = get_dem( input )

if input.DEM
    res = input.DEM;
elseif input.ElevationModel
    res = input.ElevationModel;
elseif input.DigitalElevationModel
    res = input.DigitalElevationModel;
else
    res = false;
end

end

%% GET_CENTROID_OF_LARGEST_AREA
%=========================================================================
function res = get_centroid_of_largest_area( BW )

stats = regionprops(BW, 'Area', 'Centroid');

n = numel(stats);

if n == 0
    % There are no areas
    warning('One of the ground control points have been placed outside the image.');
    res = ceil(size(BW));
    return
end

areas = zeros(n, 1);

for i = 1:n
    stat = stats(i);
    areas(i) = stat.Area;
end

[~, I] = max(areas);
biggest = stats(I);

res = biggest.Centroid;

end
