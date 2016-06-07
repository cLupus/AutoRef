% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function right_morphology = prune_morphology(images, dist_fun, max_distance, varargin)
%% Discription

% Options:
% Eccentricity: Uses the option 'Eccesntricity' in regionprops. The
% pramameters is an interval [min, max]. If 

%% Parse input

i_p = inputParser;
i_p.FunctionName = 'PRUNE_MORPHOLOGY';

% Requiered
i_p.addRequired('images', @is_image_or_images);       % Image
% Not required
% dist_fun requires max_distance
i_p.addOptional('dist_fun', @is_function);   % Distance function
% max_distance can be given without dist_fun
i_p.addOptional('max_distance', @isnumeric); % Max distance / threshold

% Optional: What to remove
i_p.addParameter('Area', false, @is_interval_or_disabled);
i_p.addParameter('Eccentricity', false, @is_interval_or_disabled);
i_p.addParameter('Solidity', false, @is_interval_or_disabled);
i_p.addParameter('AreaPerimeter', false, @is_interval_or_disabled);
i_p.addParameter('IgnoreArea', false, @is_interval_or_disabled);
i_p.addParameter('Tightness', false, @is_interval_or_disabled);   % Area / Bounding box
i_p.addParameter('Smoothing', false, @is_number_or_disabled);    % Gaussian smoothing with sigma equal to the given number
i_p.addParameter('Median', false, @islogical);
i_p.addParameter('NumElements', false, @is_number_or_disabled);
i_p.addParameter('Fill', false, @is_structure_element);
% Add
i_p.addParameter('Custom', struct([]), @is_custom);

i_p.parse(images, dist_fun, max_distance, varargin{:});

%% Dealing with the given input data
inputs = i_p.Results;

parameters = struct(...
    'Area',         create_parameter_structure(inputs.Area, {'Area'}, @(x) x, 'Interval'), ...
    'Eccentricity', create_parameter_structure(inputs.Eccentricity, {'Eccentricity'}, @(x) x, 'Interval'), ...
    'Solidity',     create_parameter_structure(inputs.Solidity, {'Solidity'}, @(x) x, 'Interval'), ...
    'AreaPerimeter',create_parameter_structure(inputs.AreaPerimeter, {'Area', 'Perimeter'},@(area, perimeter) area / perimeter, 'Interval'), ...
    'IgnoreArea',   create_parameter_structure(inputs.IgnoreArea, {'Area'}, @(x) x, 'Interval'), ...
    'Tightness',    create_parameter_structure(inputs.Tightness, {'Area', 'BoundingBox'}, @(area, BB) area / bounding_box2area(BB), 'Interval'), ...
    'Smoothing',    create_parameter_structure(inputs.Smoothing, '', @imgaussfilt3, 'Function'), ...
    'Median',       create_parameter_structure(inputs.Median, '', @medfilt2, 'Function'), ...
    'NumElements',  create_parameter_structure(inputs.NumElements, '', @num_regions , 'IntervalFunction'), ...
    'Fill',         create_parameter_structure(inputs.Fill, '', @imclose , 'Function'), ...
    'Custom',       inputs.Custom);

%% Defaults
defaults = struct(...
            'Area',             [10, 300], ...
            'Eccentricity',     [0, 0.9], ...
            'AreaPerimeter',    [1, 5], ...
            'Solidity',         [0.6471, 0.9670], ...  % Experimental data suggests values around here    
            'IgnoreArea',       [40, 300], ...       % Biggest area using the gcp-s from mosaikk was a little lss than 250 and smalles was a little bigger than 70.
            'Tightness',        [0.4, 0.9], ...
            'Smoothing',        1, ...
            'NumElements',      [0, 10], ...
            'Median',           true, ...
            'Fill',             strel('Disk', 5));

parameters = apply_deafults(parameters, defaults);

% allowed_properties = {'all', 'basic', 'Area', 'Centroid', 'BoundingBox', ...
%     'SubarrayIdx', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity',...
%     'Orientation', 'ConvexHull', 'ConvexImage', 'ConvexArea', 'Image', ...
%     'FilledImage', 'FilledArea', 'EulerNumber', 'Extrema', ...
%     'EquivDiameter', 'Solidity', 'Extent', 'PixelIdxList', 'PixelList', ...
%     'Perimeter', 'PerimeterOld', 'PixelValues', 'WeightedCentroid', ...
%     'MeanIntensity', 'MinIntensity', 'MaxIntensity', ''};

              
%% Initialization
necessary_properties = [extract_necessary_properties(parameters), {'Area'}];
% This is the properties that will be fetched from regionprops
n_img = numel(images);
right_morphology = false(n_img, 1);

%% Remove morthological incorrect images
if is_images(images)
    for i = 1:n_img
        img = images{i};
    
        fields = fieldnames(parameters);
        if in_use(parameters.Smoothing)
            fun = parameters.Smoothing.Function;
            img = fun(img, parameters.Smoothing.Values);
        end
        
        BW = dist_fun(img) <= max_distance;
        
        if in_use(parameters.Median)
            fun = parameters.Median.Function;
            BW = fun(BW, 'symmetric');
        end
        if in_use(parameters.Fill)
            BW = parameters.Fill.Function(BW, parameters.Fill.Values);
            BW = imfill(BW, 'Holes');
        end
        satisfies_all = true;
        props = regionprops(BW, necessary_properties);
        for j = 1:numel(fields)
            property = parameters.(fields{j});
            if in_use(property) && usable(property)
                satisfies_all = satisfies_all && apply_constraint(BW, property, props);
            end
        end
        right_morphology(i) = satisfies_all;
    end
else  % Binary image
    fields = fieldnames(parameters);
    BW = images; clear images;
     if in_use(parameters.Median)
        fun = parameters.Median.Function;
        BW = fun(BW, 'symmetric');
    end
    if in_use(parameters.Fill)
        BW = parameters.Fill.Function(BW, parameters.Fill.Values);
        BW = imfill(BW, 'Holes');
    end
    props = regionprops(BW, [necessary_properties, 'PixelIdxList']);
    satisfies_all = true(numel(props), 1);
    for j = 1:numel(fields)
        property = parameters.(fields{j});
        if in_use(property) && usable(property)
            [~, s] = apply_constraint(BW, property, props);
            satisfies_all = satisfies_all & s;
        end
    end
    for i = 1:numel(props)
        if ~satisfies_all(i)
            p = props(i);
            idx = p.PixelIdxList;
            BW(idx) = false;
        end
    end
    right_morphology = BW;
end
end

%%
%=========================================================================
function res = in_use(prop)
res = ~isempty(prop) && prop.Use;
end

%%
%=========================================================================
function res = usable(prop)
res = strcmp(prop.Mode, 'Interval') || strcmp(prop.Mode, 'IntervalFunction');
end

%%
%=========================================================================
function structure = create_parameter_structure(property_value, necessary_properties, fun, mode)
structure = struct(...
    'Use', will_be_used(property_value), ...
    'Values', property_value, ...
    'NecessaryProperties', {necessary_properties}, ...
    'Function', fun, ...
    'Mode', mode);
end

%%
%=========================================================================
function structure = apply_deafults( properties, defaults )

structure = properties;
fields = fieldnames(properties);
n = numel(fields);
for i = 1:n
    property = fields{i};
    property_structure = properties.(property);
    if ~isempty(property_structure) && ...
        property_structure.Use && ...
        islogical(property_structure.Values) && ...
        property_structure.Values

        structure.(property).Values = defaults.(property);
    end
end

end

%%
%=========================================================================
function output_arg = will_be_used( input_arg )

output_arg = ~islogical(input_arg) || (islogical(input_arg) && input_arg);

end

%%
%=========================================================================
function [satisfy, satisfies] = apply_constraint(BW, property, stats)

if strcmp(property.Mode, 'Interval')
    % NB: Looks only at the largest area
    n = numel(stats);
    if n == 1
        val = evaluate(property, stats);
        satisfy = is_inside(val, property.Values);
    elseif n == 0
        satisfy = false;
    else
        vals = zeros(n, 1);
        satisfies = zeros(n, 1);
        areas = zeros(n, 1);
        for i = 1:n
            vals(i) = evaluate(property, stats(i));
            satisfies(i) = is_inside(vals(i), property.Values);
            areas(i) = stats(i).Area;
        end
        [~, I] = max(areas);
        satisfy = satisfies(I(1));
    end
elseif strcmp(property.Mode, 'IntervalFunction')
    val = property.Function(BW);
    satisfy = is_inside(val, property.Values);
else
    satisfy = false;
end

end

%%
%=========================================================================
function val = evaluate(property, stats)
    necessary_properties = property.NecessaryProperties;
    num_props = numel(necessary_properties);
    field_values = cell(num_props, 1);
    for i = 1:num_props
        field_values(i) = {(stats.(necessary_properties{i}))};
    end
    val = property.Function(field_values{:});
end

function res = is_inside(val, interval)
    res = val >= interval(1) && val <= interval(2);
end


%%
%=========================================================================
function res = extract_necessary_properties(parameters)

res = {};
fields = fieldnames(parameters);

for i = 1:numel(fields)
    property = parameters.(fields{i});
    if ~isempty(property) && property.Use
        necessary = property.NecessaryProperties;
        res = [res, necessary];
    end
end
res(strcmp('', res)) = [];  % Remove empty strings

end

%%
%=========================================================================
function output_arg = is_image_or_images( input_arg )
output_arg = is_binimg(input_arg) || is_image(input_arg) || is_images(input_arg);
end

