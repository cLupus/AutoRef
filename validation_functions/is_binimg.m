% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_binimg( input_arg )
%% Discription
% A function that checks is the given input matches the criteria of a
% binary image, i.e. a two dimentinal matrix that consists only of logical
% enteries.
% 

%% Check
output_arg = islogical(input_arg) && ...
             numel(size(input_arg)) == 2;

end

