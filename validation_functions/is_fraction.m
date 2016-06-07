% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_fraction( input_arg )
%% Discription
% IS_FRACTION chekcs that the given argument is a real number between 0 and
% 1.

%% Check
output_arg = is_number(input_arg) && 0 <= input_arg && input_arg <= 1;

end
