% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_positive_number( input_arg )
%% Discription
% IS_POSITIVE_NUMBER checks if the given input is a single number, or a 
% vector of size [1 1], and that is greater or equal to 0.

%% Check
output_arg = is_number(input_arg) && input_arg >= 0;

end
