% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function BW = create_mask(img, limits)
%% Discription
% Creates a mask of the image based on the limits given for each band. It
% is in the form:
% [min_band_1, max_band_1
%  min_band_2, max_band_2
%            .
%            .
%            .
%  min_band_n, max_band_n]
% It is not neccessary that they are ordered by minimun first, and then
% maximum, but the bands must be in that order.

%% Initializing
img_size = size(img);
num_bands = img_size(3);
BW = ones(img_size(1:2));

%% Creating the mask, band for band
for i = 1:num_bands
    min_val = min(limits(i, :));
    max_val = max(limits(i, :));
    BW = BW & min_val <= img(:,:, i) & img(:,:,i) <= max_val;
end

end
