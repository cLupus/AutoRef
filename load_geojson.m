% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [points, crc, names] = load_geojson(path)
%% Discription
% Loads the geojson object located at *path*. It returns a matrix of
% points; each row is a point of the form [x y z] or [E N H] for a propper
% projection. The *crc* output is the reference coordinate system used in
% the given file.
% This function is dependent on JSONlab.

%% Load JSON object
json = loadjson(path);

num_points = numel(json.features);
points = zeros(num_points, 3);
names = cell(num_points, 1);

crc = json.crs.properties.name;

%% Fill the matriex
for i = 1:num_points
    point = json.features{i};
    coordinates = point.geometry.coordinates;
    name = point.properties.name;
    points(i, :) = coordinates;
    names{i} = name;
end

end
