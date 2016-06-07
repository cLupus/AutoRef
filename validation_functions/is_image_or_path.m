% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_image_or_path( input_arg )
%% Discription
% IS_IMAGE_OR_PATH checks if the input is a valid image or that it is a
% path to an image.

%% check
output_arg = ischar(input_arg) || is_image(input_arg);

end
