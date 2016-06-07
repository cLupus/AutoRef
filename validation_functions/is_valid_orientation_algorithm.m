% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_valid_orientation_algorithm( input_arg )
%% Discription
% IS_VALID_ORIENTATION_ALGORITHM cheks that the input is a valid choise of
% algorithm for the absolute positioning problem.

%% Check
output_arg = strcmpi(input_arg, 'ShinjiUmeyama') || ...
             strcmpi(input_arg, 'Horn') || ...
             strcmpi(input_arg, 'HornHilden') ;
end
