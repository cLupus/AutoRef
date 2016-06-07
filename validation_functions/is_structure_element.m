% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_structure_element( input_arg )
%% Discription
% IS_STRUCTURE_ELEMENT checks if the input argument is a structure element.
% It can either be a strel or a binary image.

%% Check
output_arg = isa(input_arg, 'strel') || is_binimg(input_arg);

end
