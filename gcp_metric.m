% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function measures = gcp_metric(area, BB)
%% Description
% Takes an array of areas and boundig boxes, and computes the ratio of area
% that is within the bounding box. Anything with an area less than 0.5
% cannot be a square ground control point (asuming the entire control point
% has been maked).
% The function returns an array of ratios where each component has the same
% index as it had in area and in BB.

%% Error checking
if numelements(area) ~= numelements(BB)
    error('The size of area and BB is inconsistent.');
end

%% Initializing
n = numel(area);
measures = zeros(n, 1);

%% Calculating the area metric
% The bounding box is in the form [x_min, x_max, y_min, y_max]

for i = 1:n
    x_min = BB(i, 1);
    x_max = BB(i, 2);
    y_min = BB(i, 3);
    y_max = BB(i, 4);
    bounding_box_area = (x_max - x_min + 1) * (y_max - y_min + 1);
    % Adds one to each axis because the bounding box is inclusive
    measures(i) = area(i) / bounding_box_area;
end
end
