% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function img = mask_image(RGB, mask)
%% Description
% A function that takes a mask, and an image, and sets all the areas that
% are background in the mask to be black.

%%
% Initialize output masked image based on input image.
img = RGB;

% Set background pixels where BW is false to zero.
img(repmat(~mask,[1 1 3])) = 0;
