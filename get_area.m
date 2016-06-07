% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function imgs = get_area(image, locations, area)
%% Discription
% GET_AREA extracts an area around the points in location from the given
% image. The size of the area is given by *area*. The point in location
% will then be in the middle of the area.

%% Initialization
if iscell(image)
    error('The image must be the original image, and NOT a set of images');
end

if area < 0
    area = 0;
end

image_size = size(image);
n = size(locations, 1);
imgs = cell(n, 1);

%% Extracting areas
for i = 1:n
    [x, y] = extract_location(image_size, locations(i, :), area);
    imgs{i} = image(y, x, :);
end

if n == 1
    imgs = imgs{1};
end

end

%=========================================================================
%% ADDITIONAL FUNCTIONS
%=========================================================================

%% EXTRACT_LOCATION
%=========================================================================
function [x, y] = extract_location(image_size, location, area)
%% Calculating centrum of area

location = round(location);
area = round(area);

if numel(location) == 2 || numel(location) == 3
    x = location(1) - area : location(1) + area;
    y = location(2) - area : location(2) + area;
elseif numel(location) == 4
    x_centrum = floor((location(2) - location(1)) / 2) + location(1);
    y_centrum = floor((location(4) - location(3)) / 2) + location(3);

    x = x_centrum - area : x_centrum + area;
    y = y_centrum - area : y_centrum + area;
else
    error('The numer of elements in location is wrong. It must be 2 or 4');
end

%% Error checking
if max(x) > image_size(2)
    x = min(x) : image_size(2);
end
if max(y) > image_size(1)
    y = min(y) : image_size(1);
end
if min(x) < 1
    x = 1 : max(x);
end
if min(y) < 1
    y = 1 : max(y);
end

end
