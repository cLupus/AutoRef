% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [rgb_mean, rgb_std] = mean_std_from_image(masked_image)

% Red band
R = masked_image(:,:,1);

% Green band
G = masked_image(:,:,2);

% Blue band
B = masked_image(:,:,3);

% THe extra R( ~= 0) and so forth, is to exlude 0s, but it *must* be done 
% at the time the function is called.

% Means
R_mean = mean2(R(R ~= 0));
G_mean = mean2(G(G ~= 0));
B_mean = mean2(B(B ~= 0));

% Standard deviation
R_std = std2(R(R ~= 0));
G_std = std2(G(G ~= 0));
B_std = std2(B(B ~= 0));

rgb_mean = [R_mean, G_mean, B_mean];
rgb_std = [R_std, G_std, B_std];

end