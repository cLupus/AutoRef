% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_images( input_arg )
%% Discription
% IS_IMAGES checks that the given input is a cell array of 3 banded images.

%% Initializing

num_images = numel(input_arg);

%% Check
output_arg = iscell(input_arg);
for i = 1:num_images
    output_arg = output_arg && is_image(input_arg{i});
end

end
