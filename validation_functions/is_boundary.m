% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_boundary( input_arg )
%% Discription
% Checks is the given input is a valid mode for a boundary condition;
% 'Inclusice' or 'Exclusive'.

%% Check
output_arg = strcmp(input_arg, 'Inclusive') || ...
             strcmp(input_arg, 'Exclusive');

end

