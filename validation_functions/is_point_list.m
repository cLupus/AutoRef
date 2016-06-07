% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_point_list( input_arg )
%% Discription
% IS_POINT_LIST checks is the given input is an n x 2 or n x 3 matrix of
% numerical data.

%% Check
output_arg = isnumeric(input_arg) && (size(input_arg, 2) == 2  || size(input_arg, 2) == 3);

end
