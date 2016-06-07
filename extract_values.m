% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function RGB_values = extract_values(image, BW)
%% Discription
% Extracts all values that are not 0 when the given image is masked over
% with the mask BW. The result is per band; it gives a matrix of size n x
% m, where m is the number of bands in the image.

%% Consitency check
img_size = size(image);
if any(img_size(1:2) ~= size(BW))
    error('The dimentions of the image and the mask, is inconsistent');
end

%% Initializing
num_bands = img_size(3);
RGB_values = zeros(sum(sum(BW)), num_bands);
idx = BW == 1;

%% Extracting the values
masked_img = mask_image(image, BW);
for i = 1:num_bands
    band = masked_img(:,:, i);
    RGB_values(:, i) = band(idx);
end
