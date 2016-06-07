% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_all_or_one( input_arg )
%% Discription
% IS_ALL_OR_ONE checks if the input is equal to the strings 'all' or 'one'.
% The case does not matter.

%% Check

output_arg = strcmpi(input_arg, 'all') || strcmpi(input_arg, 'one')';

end
