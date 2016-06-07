% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [images, locations] = divide_image_into_bounding_boxes(img, BW)
%% Discription
% This function divides an image up into ounding boxes of the areas as
% specified by the binary image BW.
% If only a binary image is given, images will consist of binary images.
% The function also returns the locations of the different images. This is
% done by giving the respective bounding boxes as a matrix, 'locations',
% whose rows are vectors of the form [x_min, x_max, y_min, y_max].
%
% Usage:
% [images, locations] = divide_image_into_bounding_boxes(img, BW)
% [images, locations] = divide_image_into_bounding_boxes(BW)
% 

%% Check consistencies
if nargin == 2
    img_size = size(img);
    BW_size = size(BW);

    if img_size(1:2) ~= BW_size
        error('The image and the mask have different sizes');
    end
elseif nargin == 1
    % Matlab hack
    BW = img;
end

%% Extracting bounding boxes
res = regionprops(BW, 'BoundingBox', 'PixelList');
num_obj = numel(res);

images = cell(num_obj, 1);
locations = zeros(num_obj, 4);

for i=1:num_obj
    element = res(i);
    boundingBox = element.BoundingBox;
    
    [x_min, x_max, y_min, y_max] = bounding_box2limits(boundingBox);
    
    if nargin == 2
        % Matices are indexed col, row
        images(i) = {img(y_min:y_max, x_min:x_max, :)};
    else
        images(i) = {BW(y_min:y_max, x_min:x_max)};
    end
    locations(i, :) = [x_min, x_max, y_min, y_max];
end

end
