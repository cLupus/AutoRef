% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_candidate_point_lists( input_arg )
%% Discription
% IS_CANDIDATE_POINT_LISTS checks is the given input is a cell array of candidate
% points. That is, a cell array whose elements are matrices of size n x 4
% or n x 6 of numerical data.

%% Check
output_arg = iscell(input_arg);
dims = size(input_arg{1}, 2);
if mod(dims, 2) ~= 0
    output_arg = false;
    return
end

for i = 1:numel(input_arg)
    if size(input_arg{i}, 2) ~= dims
        output_arg = false;
        return
    end
    A = input_arg{i};
    AA = A(:, 1:dims / 2);
    BB = A(:, dims / 2 + 1 : dims);
    output_arg = output_arg && is_point_list(AA) && is_point_list(BB);
end


end
