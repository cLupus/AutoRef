% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_argument = is_image( input_argument )
%% Discription
% Checks that the given input is a 3 banded image.

%% Initializing

img_size = size(input_argument);
dims = numel(img_size);

%% Check

output_argument = dims == 3 && (img_size(3) == 3 || img_size(3) == 4);  % There might be an alpha chanel

end
