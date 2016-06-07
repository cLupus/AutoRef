% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_number_or_disabled( input_arg )
%% Discription
% IS_NUMBER_OR_DISABLED checks if the input argument is a single number, or
% that it is logical. For later use, if the input argument is set to ture,
% it will be assumed that the default values are to be used, whereas if it
% is false, it will be assumed that it is disabled.

%% Check
output_arg = (isnumeric(input_arg) && all(size(input_arg) == [1 1])) || ...
             islogical(input_arg);

end
