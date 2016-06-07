% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [location, probability, imgs] = find_signal_colors(image, gcp_data, varargin)
%% Discription
% A function that finds candidates for ground control points that have a
% signal color (orange), and an estimate of how likely each point is to be
% a ground control point. The lists are sorted byr probability in decending
% order, i.e. the most likely candidate is first and the least likely
% candidate is last.

%% Parse input

i_p = inputParser;
i_p.FunctionName = 'FIND_SIGNAL_COLOR';

% Requiered
i_p.addRequired('image', @is_image_or_path);
i_p.addRequired('gcp_data', @is_point_list);

% Optional:
% Method to be used to reduce data
i_p.addParameter('LimitsMode', 'min-max', @is_min_max_std_mean);
% What is to be used with points that are too close to eachother?
% remove, average or probable.
i_p.addParameter('ReplacePointsTooClose', 'probable', @is_replace_mode);
% Toggle whether or not to use a median filter
i_p.addParameter('MedianFilter', false, @islogical);
% Toggle whether or not areas that are of size [1 x n] or [n x 1] is to be removed.
i_p.addParameter('VectorFilter', true, @islogical);
i_p.addParameter('UseMorphology', true, @islogical);
% How large does an area have to be before it is considered?
% Areas less than or equal to this value will be removed. If strictly
% larger than 1, no areas will be removed.
i_p.addParameter('MinmumArea', 0, @is_number);
% The (totatl) procentile to be GCP samples to be discarted when
% initial rough selection is done.
i_p.addParameter('PercentileRoughSelection', 0.25, @is_fraction);
% The wheight given to the standard deviation when selecting a quantile
% for the samples to be ignored when the rough selection is done.
i_p.addParameter('StandardDeviationWeight', 1, @is_number);
% This sais how much of an image can have 0 probability.
i_p.addParameter('ProbabilityPortion', 0.25, @is_fraction);
% Used to eliminate images that have too much clutter.
i_p.addParameter('MaximumClutter', 2, @is_number);
% The minimum allowed likelyhood for an area to be considered probable.
i_p.addParameter('MinimumProbability', 10^-07, @is_fraction);
% This is the smallest side length that is allowed for a sub_image. 
i_p.addParameter('MinimumSideLength', 3, @is_integer);
% The minimum distance allowed between two points
i_p.addParameter('MinimumDistanceBetweenPoints', 30, @is_number);
% The disatance in each direction from the centre of a candidate point
% that is sampled in order to determin if it is a homogenious area.
i_p.addParameter('SampleArea', 40, @is_integer);
% Specifies the maximum allowed standard deviation of a sub image.
i_p.addParameter('MaximumSpread', 0.03, @is_number);
% The maximum squared distance for a color to be away from the
% signal color sample. Max distance using emperical values:
% RGB: 19.821439604735122, Lab: 24.060660742824890.
i_p.addParameter('MaximumRoughDistance', 20, @is_number);
i_p.addParameter('MaximumFineDistance', 6, @is_number);
% Toggles whether the image is to be sharpened before processed.
i_p.addParameter('SharpenImage', false, @islogical);

i_p.addParameter('StructureElement', strel('Disk', 10), @is_structure_element);
% Toggles whether probability is to be used. If gcp_sample is very large,
% turning it on may cause the program to be VERY slow.
i_p.addParameter('UseProbability', true, @islogical);
% By what means are the center of the candidate GCP chosen?
i_p.addParameter('SelectCenter', 'Centroid', @is_center);

i_p.addParameter('MinimumMatches', -1, @is_number);

i_p.parse(image, gcp_data, varargin{:});

%% Deal with the input
input = i_p.Results;

% Required
image                       = input.image;
gcp_data                    = input.gcp_data;

% Optional
limits_method               = input.LimitsMode;
points_too_close            = input.ReplacePointsTooClose;
use_median                  = input.MedianFilter;
remove_vectors              = input.VectorFilter;
use_morphology              = input.UseMorphology;
% Internal parameters
remove_areas_leq            = input.MinmumArea;
percentile_rough_selection  = input.PercentileRoughSelection / 2;
std_weight                  = input.StandardDeviationWeight;
zero_probability_ratio      = input.ProbabilityPortion;
max_elements                = input.MaximumClutter;
min_probability             = input.MinimumProbability;
min_side                    = input.MinimumSideLength;
min_distance                = input.MinimumDistanceBetweenPoints;
sample_area                 = input.SampleArea;
max_spread                  = input.MaximumSpread;
max_rough_distance          = input.MaximumRoughDistance;
max_fine_distance           = input.MaximumFineDistance;
sharpen                     = input.SharpenImage;
SE                          = input.StructureElement;
use_probability             = input.UseProbability;
select_center               = input.SelectCenter;

%% Initializing
if ~isa(image, 'double')
    image = im2double(image);
end

if sharpen
    image = imsharpen(image);
end

if ~use_probability
    % The default option for removing points that
    % are too close to each other, is incopatible
    % with not using probability.
    points_too_close = 'average';
    warning('The option probable for ''ReplacePointsTooClose'' is incompatible ''UseProbability'' set to false.');
end

% Convert data to Lab
gcp_lab = rgb2lab(gcp_data);

% Distance metric
% RGB
C = cov(gcp_data)\eye(size(gcp_data, 2));
m = mean(gcp_data);
distance_metric = @(x) mahal_dist(x, C, m);
% Lab
C = cov(gcp_lab)\eye(size(gcp_lab, 2));
m = mean(gcp_lab);
distance_metric_lab = @(x) mahal_dist(x, C, m);

% Probability distributions
if use_probability
    [PD_L, PD_a, PD_b] = get_most_likely_distribution(gcp_lab);
    pd_L = get_pdf(PD_L); pd_a = get_pdf(PD_a); pd_b = get_pdf(PD_b);
    %TODO: Better definition that accounts for the co-variance
    prob_dist = @(x) pd_L(x(:, 1)) .* pd_a(x(:, 2)) .* pd_b(x(:, 3));
    aggregate_probability = @(img) min(quantile(img(:), 0.95));
end
spread_function = @(img) std(img(:));

%% Reducing the amount of data

% Getting limits of color for the signal colors
if strcmp(limits_method, 'min-max')
    lim = limits(gcp_data, limits_method, percentile_rough_selection);
elseif strcmp(limits_method, 'mean-std')
    lim = limits(gcp_data, limits_method, std_weight);
else
    lim = limits(gcp_data);
end

% Creating a binary image of the 
BW = create_mask(image, lim);

if use_median
    BW = medfilt2(BW, 'symmetric');
end

if remove_areas_leq > 0
    BW = remove_areas(BW, 'Area', [remove_areas_leq, Inf], 'MinBoundary', 'Exclusive');
end


%% Split data into smaler chuncks
[images, locations] = divide_image_into_bounding_boxes(image, BW);
n_img = numel(images);
if remove_vectors
    too_small = false(n_img, 1);  % Instead of logical(zeros)
    for i=1:n_img
        if size(images{i}, 1) < min_side || size(images{i}, 2) < min_side
            too_small(i) = true;
        end
    end
    images = images(~too_small);
    locations = locations(~too_small, :);
end

%% Watershed and remove too big
%TODO


%% Finer selection
[candidate_images, distance_images] = threshold_distance(images, distance_metric, max_rough_distance);
images = images(candidate_images);
locations = locations(candidate_images, :);

%% Remove morthological incorrect images

right_morphology = prune_morphology(images, distance_metric, max_rough_distance, 'Area', true, 'Eccentricity', true, 'AreaPerimeter', true);

% Remove wrong images
distance_images = distance_images(right_morphology);
images = images(right_morphology);
locations = locations(right_morphology, :);


%% Even finer selection
% Uses Lab color space, and takes some of the area round the image intop
% account.
lab_images = convert_elements(images, @rgb2lab);
[candidate_images, distance_images] = threshold_distance(lab_images, distance_metric_lab, max_fine_distance);

images = images(candidate_images);
lab_images = lab_images(candidate_images);
locations = locations(candidate_images, :);

large_images = get_area(image, locations, sample_area);
large_images = convert_elements(large_images, @rgb2lab);
right_morphology = prune_morphology(large_images, distance_metric_lab, max_fine_distance, 'Eccentricity', true, 'Area', true, 'AreaPerimeter', true, 'Tightness', true, 'Median', true, 'Fill', true);

images = images(right_morphology);
lab_images = lab_images(right_morphology);
locations = locations(right_morphology, :);
large_images = large_images(right_morphology);
distance_images = distance_images(right_morphology);

%% Calculate probabilities
if use_probability
    n_img = numel(images);

    prob_imgs = cell(n_img, 1);

    for i = 1:n_img
        prob_imgs{i} = apply_fun2img(prob_dist, lab_images{i});
    end
end


%% Remove the (impossibly) unlikely candidates
if use_probability
    n_img = numel(images);
    no_chance = false(n_img, 1);
    for i = 1:n_img
        prob_img = prob_imgs{i};
        if max(max(prob_img)) < min_probability
            no_chance(i) = true;
        else
            area = prod(size(prob_img));
            zero_chance = sum(sum(prob_img == 0));
            if zero_chance / area >= zero_probability_ratio
                no_chance(i) = true;
            end
        end
    end

    % Remove the unlikely candidates
    distance_images = distance_images(~no_chance);
    images = images(~no_chance);
    lab_images = lab_images(~no_chance);
    locations = locations(~no_chance, :);
    prob_imgs = prob_imgs(~no_chance);
    large_images = large_images(~no_chance);

end

%% Calculate probabilities
if use_probability
    n_img = numel(images);
    probability = zeros(n_img, 1);
    for i = 1:n_img   
        prob_img = prob_imgs{i};
        probability(i) = aggregate_probability(prob_img);
    end
end

%% Compute output
n_img = numel(images);

location = zeros(n_img, 2);
% This can be done earlier; when we look for
% images that have morphological errors
if strcmpi(select_center, 'Probability')
    probability = zeros(n_img, 1);
    for i = 1:n_img   
        prob_img = prob_imgs{i};
        [row, col] = find(prob_img == max(max(prob_img)));
        if numel(row) >= 2 || numel(col) >= 2
            row = round(mean(row));
            col = round(mean(col));
        end
        bounding_box = locations(i, :);
        x_min = bounding_box(1);
        y_min = bounding_box(3);
        location(i, :) = [x_min + col, y_min + row];
        probability(i) = aggregate_probability(prob_img);
    end
elseif strcmpi(select_center, 'Mahalanobis')
    for i = 1:n_img
        dist_img = distance_images{i};
        [row, col] = find(dist_img == min(dist_img(:)));
        if numel(row) >= 2 || numel(col) >= 2
            row = round(mean(row));
            col = round(mean(col));
        end
        bounding_box = locations(i, :);
        x_min = bounding_box(1);
        y_min = bounding_box(3);
        location(i, :) = [x_min + col, y_min + row];
    end
elseif strcmpi(select_center, 'Centroid')
    for i = 1:n_img
        BW = distance_images{i} <= max_fine_distance;
        res = regionprops(BW, 'Centroid');
        centroid = res.Centroid;
        col = round(centroid(1)); row = round(centroid(2));
        bounding_box = locations(i, :);
        x_min = bounding_box(1);
        y_min = bounding_box(3);
        location(i, :) = [x_min + col, y_min + row];
    end
end

%% Deal with points that are too close
n_img = numel(images);

Z = squareform(pdist(location));
if strcmp(points_too_close, 'off')
    % Do nothing
elseif strcmp(points_too_close, 'remove')
    [row, col] = find(Z < min_distance & Z ~= 0);
elseif strcmp(points_too_close, 'average')
    row = false(n_img, 1);
    for i = 1:n_img
        if row(i) == 1
            % We have already decided to remove this
            continue
        end
        too_close = find(Z(i, :) < min_distance & Z(i, :) ~= 0);
        if numel(too_close) > 0
            too_close = [too_close i];
            mean_position = mean(location(too_close, :));
            D = sqrt((bsxfun(@minus, location(too_close, :), mean_position)).^2);
            min_D = min(D);
            keep = find(D(:, 1) == min_D(1) & D(:, 2) == min_D(2));
            if numel(keep) > 1
                keep = keep(1);  % In case multiple are as close.
            end
            row(too_close) = true;
            row(too_close(keep)) = false;
        end
    end
elseif strcmp(points_too_close, 'probable')
    %TODO
    row = false(n_img, 1);
    for i = 1:n_img
        if row(i) == 1
            % We have already decided to remove this
            continue
        end
        too_close = find(Z(i, :) < min_distance & Z(i, :) ~= 0);
        if numel(too_close) > 0
            too_close = [too_close i];
            keep = find(probability == max(probability(too_close)));
            if numel(keep) > 1
                keep = keep(1);  % In case multiple are as close.
            end
            row(too_close) = true;
            row(keep) = false;
        end
    end
end

distance_images(row) = [];
images(row) = [];
location(row, :) = [];
if use_probability
    prob_imgs(row) = [];
    probability(row) = [];
end
large_images(row) = [];

%% Calculate how "close" the areas are to a circle
n_img = numel(images);
closeness = zeros(n_img, 1);

for i = 1:n_img
    img = large_images{i};
    BW = distance_metric_lab(img) < max_fine_distance;
    BW = imclose(BW, SE);
    BW = imfill(BW, 'Holes');
    stats = regionprops(BW, 'Area', 'BoundingBox');
    n_stats = numel(stats);
    areas = zeros(n_stats, 1);
    temp_closeness = zeros(n_stats, 1);
    for j = 1:n_stats
        stat = stats(j);
        region_area = stat.Area;
        bounding_box = stat.BoundingBox;
        [x_min, x_max, y_min, y_max] = bounding_box2limits(bounding_box);
        width = x_max - x_min + 1;
        height = y_max - y_min + 1;
        side = max([width, height]);
        
        areas(j) = region_area;
        temp_closeness(j) = abs(region_area / side^2 - pi / 4);
    end
    [~, I] = max(areas);  % Ascending order
    closeness(i) = temp_closeness(I(end));
end

[~, I] = sort(closeness);

%% Sort the candidates
%[probability, I] = sort(probability, 'descend');
if use_probability
    probability = probability(I);
else
    probability = 0;
end
location = location(I, :);

imgs = images(I);

end

%% Additional functions

%%
%=========================================================================
function [within, distimgs] = threshold_distance(images, distance_metric, threshold)
n_img = numel(images);
candidate_images = false(n_img, 1);
distance_images = cell(n_img, 1);

for i = 1:numel(images)
    image_part = images{i};
    dist_part = distance_metric(image_part);
    BW_part = dist_part <= threshold;
    BW_part = medfilt2(BW_part, 'symmetric');  % Removes images that only have a pixel or two.
    if any(any(BW_part))
        candidate_images(i) = true;
        distance_images{i} = dist_part;
    end
end

% Remove empty cells
distimgs = remove_empty_cells(distance_images);
within = candidate_images;
end

%%
%=========================================================================
function [PD_band1, PD_band2, PD_band3] = get_most_likely_distribution(data)
    
    PD_band1 = fitdist(data(:, 1), 'Kernel', 'Kernel', 'Normal');
    
    PD_band2 = fitdist(data(:, 2), 'Kernel', 'Kernel', 'Normal');
    
    PD_band3 = fitdist(data(:, 3), 'Kernel', 'Kernel', 'Normal');
end

%%
%=========================================================================
function cellarray = convert_elements(images, fun)
    n = numel(images);
    cellarray = cell(n, 1);
    
    for i = 1:n
        e = images{i};
        cellarray{i} = fun(e);
    end
end

%%
%=========================================================================
function val = homogeneous_estimate(image)
    %TODO
end

%%
%=========================================================================
function output_arg = is_center( input_arg )
%% Discription
% IS_CENTER checks if the given argument is a valid method of selecting
% the center of a candidate GCP.

%% Check
output_arg = strcmpi(input_arg, 'Centroid') || ...
             strcmpi(input_arg, 'Probability') || ...
             strcmpi(input_arg, 'Mahalanobis');

end
