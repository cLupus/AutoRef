% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_min_max_std_mean( input_arg )
%% Discription
% Checks is the given input is a 'min-max', 'max-min', 'std-mean', or
% 'mean-std'; valid modes.

%% Check
output_arg = strcmpi(input_arg, 'min-max') || ...
             strcmpi(input_arg, 'std-mean') || ...
             strcmpi(input_arg, 'max-min') || ...
             strcmpi(input_arg, 'mean-std');

end

