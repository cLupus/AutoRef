% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function res = is_neighbor(point, points, neigbourhood)
%% Description
% Checks if the given point is a neighbour of the given set of points. The
% neighbourhood is defined by th eneigbourhood matrix.


%% Initializing
num_centers = sum(sum(find(neigbourhood == 2)));

% Finding the location of the given point in the neighborhood matrix
if num_centers > 1
    error('The given neigbourhood matrix has more than one centra');
elseif num_centers == 1
    % There is one center, and we need to find it
    [p_x_rel, p_y_rel] = find(neigbourhood == 2);
else
    % There is not given a center, so use default
    [n, m] = size(neigbourhood);
    
    % By taking the ceil, it will always be the bottom right if n or m is
    % even, and it will be the centre it n or m is odd, or a combination of
    % the two if n is odd and m is even, or vice versa.
    p_x_rel = ceil(n / 2);
    p_y_rel = ceil(m / 2);
end

p_x_abs = point(1);
p_y_abs = point(2);

res = false;

neigbourhood_size = size(neigbourhood);

%% Poing through the set of points

for i = 1:numel(points)
    current_point = points(i,:);
    p_x = p_x_abs - current_point(1) + p_x_rel;
    p_y = p_y_abs - current_point(2) + p_y_rel;
    
    if p_x > neigbourhood_size(2) || p_x < 1 || p_y < 1 || p_y > neigbourhood_size(1)
        continue
    elseif neigbourhood(p_y, p_x) == 1
        res = true;
        return
    end
end
end

