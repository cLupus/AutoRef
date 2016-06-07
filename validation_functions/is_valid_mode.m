% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_valid_mode( input_arg )
%% Discription
% IS_VALID_MODE checks that the given (set of) string(s) is a valid mode
% for the function "prune_morphology.m".

%% Define valid modes
modes = {'Interval', 'Function', 'IntervalFunction'};

%% Check
output_arg = any(strcmp(input_arg, modes));

end
