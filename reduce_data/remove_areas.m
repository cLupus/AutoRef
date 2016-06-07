% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function BW = remove_areas(binimg, properties, interval, varargin)
%% Description
% The function removes all areas in the binary image whose areas, or
% regions are outside a certain interval relative to a certain property,
% or properties. If there is only one property, there is no need to
% specify a function, but if there are multiple properties, then a
% 'Function' must be specified. The function must take as input a vector
% of the same size as there are properties in the cellarray *properties*.
% Note, if a single property is given, it can be a normal string.
% The flags 'MinBoundary' and 'MaxBoundary' can be set to 'Inclusive' or
% 'Exclusive' independent of eachother. The default is 'Inclusive'. This
% means that the given *interval* includes the boundaries, and will be
% cunted as inside the interval. If 'Exclusive' is chosen for ether end,
% the value at the end of the interval will be counted as outside the
% allowed interval.
%
% Leagal calls:
% BW = remove_areas(binimg, property, interval)
% BW = remove_areas(binimg, property, interval, options )
% BW = remove_areas(binimg, properties, interval, 'Function', @(x) ..., options )
% options are 'MinBoundary', 'MaxBoundary', both of wich have 'Inclusive'
% and 'Exclusive' as parameters, while 'Function' takes an arbitrary
% function that is subject to two (2) constraints:
% 1. The input must be a single vector, whose length is the same as the
%    number of properties (can also be one, if there is only one property).
% 2. The output of the function must be a scalar.

%%
% %*$f: \mathbb{R}^{n} \rightarrow{} \mathbb{R}$*)



%% Checking input arguments
default = 'Inclusive';

% Defining validation functions

i_p = inputParser;
i_p.FunctionName = 'REMOVE_AREAS';

% Requiered
i_p.addRequired('binimg', @is_binimg);          % Binary image
i_p.addRequired('properties', @is_properties);  % Property / Properties
i_p.addRequired('interval', @is_interval);      % interval to be used

% Optional
i_p.addParameter('MinBoundary', default, @is_boundary);
i_p.addParameter('MaxBoundary', default, @is_boundary);
i_p.addParameter('Function', @(x) x, @is_function);

i_p.parse(binimg, properties, interval, varargin{:});

%% Dealing with the given input data
inputs = i_p.Results;

min_val = interval(1);
max_val = interval(2);

min_boundary = inputs.MinBoundary;
max_boundary = inputs.MaxBoundary;
fun = inputs.Function;

% Is there multiple properties, or a single property?
if ~iscellstr(properties)
    % There is only one property.
    properties = {properties};
end

%% Defining the comperation criteria

outside_interval = make_outside_interval_checker(min_boundary, max_boundary);

%% Getting properties
vars = properties;
vars{end + 1} = 'PixelIdxList';

props = regionprops(binimg, vars);

BW = binimg;

for i = 1:numel(props)
    field_vals = zeros(numel(properties), 1);
    element = props(i);
    
    for j = 1:numel(properties)
        field_vals(j) = element.(cell2mat(properties(j)));
    end
    
    val = fun(field_vals);
    
    if outside_interval(val, min_val, max_val)
        pixels = element.PixelIdxList;
        BW(pixels) = 0;
    end
end

end
