% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_replace_mode( input_arg )
%% Discription
% Checks is the given input is a valid mode for what to do with points that
% are too close to eachother.

%% Check
output_arg = strcmpi(input_arg, 'probable') || ...
             strcmpi(input_arg, 'average')  || ...
             strcmpi(input_arg, 'remove');

end

