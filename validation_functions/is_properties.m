% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_properties( input_arg )
%% Discription
% IS_PROPERTIES checks whether or not the given input can be considered a
% list of valid properties to be used in regionprops. It does this by
% checking that the input is either a cell array of string, or a single
% string.
%


%% List of valid strings:
properties = {'all', 'basic', 'Area', 'Centroid', 'BoundingBox', ...
    'SubarrayIdx', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity',...
    'Orientation', 'ConvexHull', 'ConvexImage', 'ConvexArea', 'Image', ...
    'FilledImage', 'FilledArea', 'EulerNumber', 'Extrema', ...
    'EquivDiameter', 'Solidity', 'Extent', 'PixelIdxList', 'PixelList', ...
    'Perimeter', 'PerimeterOld', 'PixelValues', 'WeightedCentroid', ...
    'MeanIntensity', 'MinIntensity', 'MaxIntensity', ''};

%% Check

if iscellstr(input_arg)
    output_arg = true;
    for i = 1:numel(input_arg)
        output_arg = output_arg && ...
            any(strcmp(input_arg(i), properties));
    end
elseif ischar(input_arg)
    output_arg = any(strcmp(input_arg, properties));
else
    output_arg = false;
end


end
