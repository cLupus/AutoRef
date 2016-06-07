% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_function( input_arg )
%% Discription
% Checks is the given input is a function handle.

%% Check
output_arg = isa(input_arg, 'function_handle');

end

