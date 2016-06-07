% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [sorted, I] = sort_based_on_function( BWs, properties, fun, order)
%% Discription
% SORT_BASED_ON_FUNCTION sorts a set of elements (such as binary images)
% based on a given function

%% Initialization
n = numel(BWs);
vals = zeros(n, 1);
if nargin == 2
    order = 'ascend';
end

%% Evaluate function
for i = 1:n
    BW = BWs{i};
    stats = regionprops(BW, properties{:});
    field_values = cell(num_props, 1);
    for j = 1:num_props
        field_values(j) = {(stats.(properties{j}))};
    end
    vals(i) = fun(field_values{:});
end

%% Sort results
[~, I] = sort(vals, order);
sorted = BWs(I);

end
