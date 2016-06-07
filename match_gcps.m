% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function varargout = match_gcps(image_points, gcps, varargin)
%% Description
% This function matches ground controll points from a orthophoto with the
% actual coordinates ground controll points. The input points is the
% relative coordinates of the ground controll points in the orthophoto /
% image. Not all of these points needs to be actual coordinates. The
% function is able to handle missing points, and false positives.
% The Input prameter gcps is a list of the world coordinates of the ground
% controll points.
%
% USAGE:
% matches = match_gcps(image_points, gcps)
% matches = match_gcps(image_points, gcps, options)
% [CM, ST, RMSE] = match_gcps(image_points, gcps, 'GetOptimal', true, ___)
%
%
%
% Valid options
%   'ImageTPPMode'      The mode of how the topological point pattern is to
%                       be used. The valid modes area 'all', 'one', If
%                       'one' is selected, a single point will be chosen as
%                       an anchor point. Unless 'ImageTPPIndex' is given as
%                       well, this point will be chosen at random. If 'all'
%                       is given insted, the algorithm will choose the
%                       point pattern for the image that gives the best
%                       RMSE with all the possible point patterns in the
%                       ground controll point set. This is slower than
%                       selecting 'one'.
%                       Default is 'one'.
%   'ImageTPPIndex'     The index of which point to be used as the anchor
%                       point in the set of points from the image. If the
%                       index is negative or beyond the number of points in
%                       the set, a point will be chosen at random.
%                       Default is -1 (random).
%   'MinimumMatches'    The minimum points necessary for a set of matching
%                       points to be considered for a true matching.
%                       Default is the number of unknowns in the absolute
%                       matching problem plus one, e.g. is the points are
%                       in 2D, this value will be 2, while if the points
%                       are in 3D, it will be 3.
%   'RadiusThreshold'   The threshold used when comparing radiuses. If the
%                       difference in radia between the point pattern in
%                       the image and the point pattern in the ground
%                       control points is less than the given threshold, it
%                       will be considered a match.
%                       Default is 0.1.
%   'AngleThreshold'    The threshold used when comparing angles. If the
%                       difference in angles between the point pattern in
%                       the image and the point pattern in the ground
%                       control points is less than the given threshold, it
%                       will be considered a match.
%                       Default is 0.1.
%   'DegreesFreedom'    The number of points that is desireable beyond what
%                       is necessary to get a unique solution to the
%                       absolute orientation problem. Default is 1.
%   'MinMatchedPoints'  The minimum number of points that are to matched.
%                       Default is the number of points to get a uniqe
%                       solution.
%   'GetIndices'        A boolean falg toggeling wether or not just the
%                       indices of matching points are to be returned. If
%                       true, only the indices of the points that are
%                       matching eachother will be returned. If false, the
%                       full coordinates will be returned in an n x 2 * d
%                       matrix where d is the dimentionality of the points.
%                       Default is false.
%   'GetOptimal'        A boolean flag that toggles wether the output is
%                       the best candidate matching, along with the
%                       transformation parameters and the root mean square
%                       error of the transformation.
%                       Default is false.
%                       NB: When using this option, 'GetIndices' will not
%                       be a valid argument, and will be ignored.
%
%   'OrientationAlgorithm'  The algorithm to be used when computing the
%                       optimal absolute orientation. This option is anly
%                       applicable when the 'GetOptimal'-flag is set to
%                       true. The valid options are 'ShinjiUmeyama' and
%                       'Horn'.
%                       Default is 'Horn'.
%
%   'MaxDistance'       Specifies the maximum allowed scaled distance
%                       between the different points in the pattern.
%                       Default is Inf, i.e. no limit.
%
%   'ImageLimit'        Toggles whether the set of topological points
%                       from the image are limited to the maximum
%                       distance of the topological points of the
%                       ground control points.
%                       Default is false.
%
%   'GCPLimit'          Toggles whether the set of topological points
%                       from the ground control points are limited to
%                       the maximum distance of the topological
%                       points of the image.
%                       Default is false.
%
%   'UseHornScale'      Toggles whether the scale factor suggested in
%                       Horn (1986), and Horn et. al. (1988) is to be
%                       used instead of the scale factor suggested in
%                       Umeyama (1991) for the algorithm
%                       'ShinjiUmeyama'.
%                       Default is false.
%
% If 'GetIndices' is set to true matches will be a cell array of cellarrays
% of matrices having rows [i, j] where the indices is the points in of
% *image_points* and *gcps* respectively. If it is set to false, however,
% it will return a cell array each containing a n x 2 * d matrix of the
% points in image_points and gcps. The points in the first is in the first
% two columns of the cell array, while the latter is in the latter two.
% I.e. [x_i y_i N_j E_j]. d is the number of dimention in the points.
%
% NB: If *image_points* and *gcps* have different dimentions, the lowest
% dimention will be used, i.e. id on is 2D and the other is 3D, the output
% will only be 2D.

%% Parse input

i_p = inputParser;
i_p.FunctionName = 'MATCH_GCPS';

% Requiered
i_p.addRequired('image_points', @is_point_list);
i_p.addRequired('gcps', @is_point_list);

% Optional: What to remove
i_p.addParameter('ImageTPPMode', 'one', @is_all_or_one);
i_p.addParameter('ImageTPPIndex', -1, @is_number);
i_p.addParameter('MinimumMatches', -1, @is_number);                  % Default is a 5 if the points are 2D, and 7 if they are 3D
i_p.addParameter('RadiusThreshold', 0.21, @is_number);
i_p.addParameter('AngleThreshold', 0.21, @is_number);
i_p.addParameter('DegreesFreedom', 1, @is_positive_integer);
i_p.addParameter('GetIndices', false, @islogical);
i_p.addParameter('GetOptimal', false, @islogical);
i_p.addParameter('ImageCoordinateSystem', 'xy', @is_coordinate_system);
i_p.addParameter('GCPCoordinateSystem', 'NE', @is_coordinate_system);
i_p.addParameter('OrientationAlgorithm', 'Horn', @is_valid_orientation_algorithm);
i_p.addParameter('MaxDistance', Inf, @is_positive_number);
i_p.addParameter('GCPLimit', false, @islogical);
i_p.addParameter('ImageLimit', false, @islogical);
i_p.addParameter('UseHornScale', false, @islogical);


i_p.addParameter('Debug', false, @islogical);
i_p.addParameter('DebugPath', 'D:\Users\sindr\Dropbox\Dokumenter\Skole\NTNU\Master\Masteroppgave\data\resultater\kandidater\', @ischar);


i_p.parse(image_points, gcps, varargin{:});

%% Deal with the input
input = i_p.Results;

% Required
image_points            = input.image_points;
gcps                    = input.gcps;

% Optional
i                       = input.ImageTPPIndex;
mode                    = input.ImageTPPMode;
image_coor              = input.ImageCoordinateSystem;
gcp_coor                = input.GCPCoordinateSystem;

sufficient_points       = input.MinimumMatches;

delta_r                 = input.RadiusThreshold;
delta_theta             = input.AngleThreshold;

dof                     = input.DegreesFreedom;

use_indices             = input.GetIndices;
use_verification        = input.GetOptimal;

max_distance            = input.MaxDistance;
image_limit             = input.ImageLimit;
gcp_limit               = input.GCPLimit;
use_horn_scale          = input.UseHornScale;

% Debug
debug_mode              = input.Debug;
debug_path              = input.DebugPath;

orientation_algorithm   = input.OrientationAlgorithm;

%% Initialization
dim = min([size(image_points, 2), size(gcps, 2)]);

% Determining the minimum needed points to get unique solution
minimum_num_points = ceil(((dim - 1) + dim + 1) / dim); % Angles, translation and scaling, and there are *dim' number of equations per point
if sufficient_points <= 0
    sufficient_points = (minimum_num_points * dim + dof) / dim;
elseif sufficient_points <= minimum_num_points
    warning('The number of minimum matches is lower or equal to the number of points requiered to solve the absolute orientation problem');
end

if use_verification
    % We need the actual points.
    use_indices = false;
end

if strcmpi(image_coor, 'yx')
    image_points = [image_points(:, 2) image_points(:, 1)];
end
if strcmpi(gcp_coor, 'NE')
%     gcps = [gcps(:, 2) gcps(:, 1)];
end

image_points = image_points(:, 1:dim);
gcps = gcps(:, 1:dim);


if use_verification
    varargout = cell(3, 1);
else
    varargout = cell(1);
end

if gcp_limit && image_limit
    TPPs_image = create_TPPs_for_image(image_points, i, max_distance, mode);
    TPPs_gcp = create_TPPs_for_gcp(gcps, max_distance);
    d = min([find_maximum_distance(TPPs_image), ...
             find_maximum_distance(TPPs_gcp), max_distance]);
    TPPs_image = prune_tpp(TPPs_image, d);
    TPPs_gcp = prune_tpp(TPPs_gcp, d);
elseif gcp_limit
    % The GCPs are limited by the maximum distance of image TPP
    TPPs_image = create_TPPs_for_image(image_points, i, max_distance, mode);
    d = find_maximum_distance(TPPs_image);
    TPPs_gcp = create_TPPs_for_gcp(gcps, min([max_distance, d]));
elseif image_limit
    TPPs_gcp = create_TPPs_for_gcp(gcps, max_distance);
    d = find_maximum_distance(TPPs_gcp);
    TPPs_image = create_TPPs_for_image(image_points, i, min([max_distance, d]), mode);    
else
    TPPs_gcp = create_TPPs_for_gcp(gcps, max_distance);
    TPPs_image = create_TPPs_for_image(image_points, i, max_distance, mode);
end

%% Matching

matches = match_points(TPPs_image, TPPs_gcp, sufficient_points, delta_r, delta_theta, mode, debug_mode, debug_path);

%% Finallizing the output

n_matches = numel(matches);

for ii = 1:n_matches
    CM = matches{ii};
    acm = CM{1};
    idx_gcp = CM{2}; idx_img = CM{3};
    matches{ii} = [TPPs_image{idx_img}.Indices(acm(:, 1)), TPPs_gcp{idx_gcp}.Indices(acm(:, 2))];
end

if ~use_indices
    for ii = 1:n_matches
        CM = matches{ii};
        matches{ii} = [image_points(CM(:, 1), :), gcps(CM(:, 2), :)];
    end
end
if use_verification
    [CM, ST, RMSE] = verification_algorithm(matches, orientation_algorithm, use_horn_scale);
    varargout{1} = CM; varargout{2} = ST; varargout{3} = RMSE;
else
    varargout{1} = matches;
end


end

%% TOPOLOGICAL_POINT_PATTERN
%=========================================================================
function TPP = topologival_point_pattern( points, i, d )
%% Discription
% TOPOLOGICAL_POINT_PATTERN computes the topological point pattern (TPP) of
% the given set of points, using the i-th point as an anchor point.
% The output is a struct with the fields 'TPP', 'Indices', 'AnchorPoint',
% 'AnchorPointIndex', and 'ScalingFactor'.
% More specifically:
%   'TPP' is a sorted list of polar cooredinates for each
% point in the input set. The set is sorted lexicographically (r, theta).
%   'Indices' is a set of indices for a one-to-one correspondence with the
% points in the given set. They are indexed by their order in TPP. I.g. if
% the i-th element of I is j, that means that the i-th element in *TPP* is
% equivelent to the j-th point in *points*.
%   'AnchorPoint' is the absolute position of the anchor point.
%   'AnchorPointIndex is the index that was used when computing the
% topological point pattern.
%   'ScalingFactor' is the unit distance of r, i.e. the distance between the
% anchor point and its closest neighbor.

%% Initialization
n = size(points, 1) - 1;

anchor_point = points(i, :);
if nargin == 2
    d = Inf;
end

%% Procedure
% Translate all points relative the anchor point
points = bsxfun(@minus, anchor_point, points);

% Calculate distances
D = sqrt(sum(points.^2, 2));

% Find the closest point to the anchor point
D(D == 0) = Inf;    % Hack to avoid getting the same point when using min(D(D ~= 0)) or min(nonzero(D))
[~, I] = min(D);
D(D == Inf) = 0;    % Hack to avoid getting the same point when using min(D(D ~= 0)) or min(nonzero(D))

% Since the points have been translated, the vector of the prixipal axis
% coincides with the closest point, when we treat it as a vector
principal_axis = points(I, :);
principal_angle =  atan2(principal_axis(2), principal_axis(1));

scaling = sqrt(principal_axis(1)^2 + principal_axis(2)^2);

r = D / scaling;
theta = rem(atan2(points(:, 2), points(:, 1)) - principal_angle, pi);

% Remove those that are too far away
I = r <= d;
r = r(I);
theta = theta(I);

% Make the angle interval [0 2pi] instead of [-pi, pi]
theta(theta < 0) = theta(theta < 0) + 2*pi;

%% Computing outputs
% Topoligical point pattern
[~, I] = sortrows([r min([theta, 2 * pi - theta], [], 2)]);
pattern = [r(I), theta(I)];
pattern(1, 2) = 0;  % Ensure that the angle of the anchor point is zero.

% Anchor point
ap = anchor_point;

% Scaling factor
s = scaling;

% Gather it all together in a struct
TPP = struct(...
    'TPP', pattern, ...
    'Indices', I, ...
    'AnchorPoint', ap, ...
    'AnchorPointIndex', i, ...
    'ScalingFactor', s);

end

%% IS_SUBSET
%=========================================================================
function res = is_subset(TPPa, TTPb)
%% Discription
% Checks if TPPa is a subset of TTPb

%%
res = true;

end

%% PRUNE_TPPs
%=========================================================================
function TPP = prune_tpp(TPP, max_distance)
%% Discription
% Removes all points that are further away from the anchor point than
% the given distance.

%% Prune
for i = 1:numel(TPP)
    tpp = TPP{i};
    pattern = tpp.TPP;
    I = pattern(:, 1) <= max_distance;
    tpp.TPP = pattern(I, :);
    tpp.Indices = tpp.Indices(I);
    TPP{i} = tpp;
end

end


%% EXTRACT_MATCHING_PAIRS
%=========================================================================
function matches = extract_matching_pairs(TPPa, TPPb, delta_r, delta_theta)
%% Discription
% Extract the points that matches in the two given sets
% Input: Two sets of Topological Point Patterns; TPPa and TPPb, along with
% a set of thresholds; $\Delta{} r$ and $\Delta{} \theta$ for the minimal
% accepted difference between the radius and angle in polar coordinates
% respectively.

%% Initialization
n_a = size(TPPa, 1);
n_b = size(TPPb, 1);

matches = zeros(max([n_a, n_b]), 2);

i = 1;
j = 1;

%% Look for matching pairs

while i <= n_a && j <= n_b

    theta_a = TPPa(i, 2);
    theta_b = TPPb(j, 2);

    diff_r     = abs(TPPa(i, 1) - TPPb(j, 1));
    diff_theta = min([abs(theta_a - theta_b), ...
                      theta_a + (2*pi - theta_b), ...% b is bellow the axis
                      theta_b + (2*pi - theta_a)]); % a is bellow the axis
    if diff_r <= delta_r && diff_theta <= delta_theta
        matches(i, :) = [i j];
        i = i + 1;
        j = j + 1;
    elseif TPPa(i, 1) > TPPb(j, 1)
        j = j + 1;
    elseif TPPa(i, 1) < TPPb(j, 1)
        i = i + 1;
    elseif i + 1 <= n_a && j + 1 <= n_b
        % This means the points are close enough, but the angle is off
        if abs(TPPa(i + 1, 1) - TPPb(j, 1)) <= diff_r && ...
                abs(TPPa(i, 1) - TPPb(j + 1, 1)) <= diff_r && ...
                abs(TPPa(i + 1, 2) - TPPb(j, 2)) < diff_theta && ...
                abs(TPPa(i, 2) - TPPb(j + 1, 2)) < diff_theta
            % Both next candidates are closer than the previous, and both
            % are within the theresholds of $r$ and $\theta$, so we choose
            % the one with the smallest angle
            if abs(TPPa(i + 1, 2) - TPPb(j, 2)) < abs(TPPa(i, 2) - TPP(j + 1, 2))
                i = i + 1;
            else
                j = j + 1;
            end
        elseif abs(TPPa(i + 1, 1) - TPPb(j, 1)) <= diff_r && abs(TPPa(i + 1, 2) - TPPb(j, 2)) < diff_theta
            i = i + 1;
        elseif abs(TPPa(i, 1) - TPPb(j + 1, 1)) <= diff_r && abs(TPPa(i, 2) - TPPb(j + 1, 2)) < diff_theta
            j = j + 1;
        else
            i = i + 1;
            j = j + 1;
        end
    else
        i = i + 1;
        j = j + 1;
    end
end

% Removes the empty rows
matches( ~any(matches, 2), :) = [];

end

%% MATCH_POINTS
%=========================================================================
function matches = match_points(TPPs_image, TPPs_gcp, sufficient_points, delta_r, delta_theta, mode, debug_mode, debug_path)

n_gcp = numel(TPPs_gcp);
n_img = numel(TPPs_image);

if strcmpi(mode, 'all')
    n = n_img;
else
    n = 1;
end

CCM = cell(n_gcp, n);

for ii = 1:n_gcp
    for jj = 1:n
        TPP_image   = TPPs_image{jj};
        TPP_gcp     = TPPs_gcp{ii};
        if is_subset(TPP_image, TPP_gcp)
            acm = extract_matching_pairs(TPP_image.TPP, TPP_gcp.TPP, delta_r, delta_theta);
            if debug_mode
                plot_TPPs(TPP_image.TPP, TPP_gcp.TPP);
                saveas(gcf, strcat(debug_path, num2str(ii), '-', num2str(jj)), 'png');
                close all
            end
            if size(acm, 1) >= sufficient_points
                CCM{ii, jj} = {acm, ii, jj};
            end
        end
    end
end

matches = remove_empty_cells(CCM);

if numel(matches) == 0 && sufficient_points >= 2
    warning(strcat('The number of maching points is too much (', ...
        num2str(sufficient_points), '). Trying again with', ' ', ...
        num2str(sufficient_points - 1), ' matching points.'));
    matches = match_points(TPPs_image, TPPs_gcp, sufficient_points - 1, delta_r, delta_theta, mode, debug_mode, debug_mode );
elseif numel(matches) == 0
    error('There are no matching points.');
end

end

%% CREATE_TPPS_FOR_IMAGE
%=========================================================================
function TPPs_image = create_TPPs_for_image(image_points, i, max_distance, mode)
%% Discription
% Creates a collection of TPP from the image
n_img = size(image_points, 1);

if strcmpi(mode, 'one')
    if i <= 0 || i > n_img
        % Discrete Uniform from 1 to n_img inlusive
        i = random('unid', n_img);
    end
    TPPs_image = {topologival_point_pattern(image_points, i, max_distance)};
else
    TPPs_image = cell(n_img, 1);
    for ii = 1:n_img
        TPPs_image{ii} = topologival_point_pattern(image_points, ii, max_distance);
    end
end

end

%% CREATE_TPPS_FOR_GCP
%=========================================================================
function TPPs_gcp = create_TPPs_for_gcp(gcps, max_distance)
%% Discription
% Creates a collection of topological point patterns from the points
% in the set of ground control points.

%% Initialization
n_gcp = size(gcps, 1);

TPPs_gcp = cell(n_gcp, 1);

%% Compute TPPs
for ii = 1:n_gcp
    TPPs_gcp{ii} = topologival_point_pattern(gcps, ii, max_distance);
end

end

%% FIND_MAXIMUM_DISTANCE
%=========================================================================
function d = find_maximum_distance(TPP)
%% Discription
% Finds the maximum distance in the given topological point pattern.

%% Find trhe distnace
d = 0;
for ii = 1:numel(TPP)
    if iscell(TPP)
        pattern = TPP{ii}.TPP;
    else
        pattern = TPP{ii};
    end
    
    tmp_d = pattern(end,1);
    if tmp_d > d
        d = tmp_d;
    end
end

end
