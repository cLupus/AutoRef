% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function neigbours = find_neighbours_to_point(point, points, neigbourhood)
%% Description
% This function finds all the neighbours of the given point among the given
% set of points as defined my the neigbourhood matrix.
% The function returns a set of points that are alle neighbours, including
% the given point.
% The neigbourhood matrix should be an n by m matrix where n and m are odd.
% If that is not the case, the lower right element will be used as the
% location of the given point unless any element in the matrix i 2, in
% which case, the element with value 2 is used as the 'center'

%% Initializing
num_points = numel(points);

neigbours = [point];

%% Finding neighbourhoods

for i = 1:num_points
    current_point = points(i,:);
    if is_neighbor(current_point, points, neigbourhood)
        neigbours = [neigbours; current_point];
    end
end

end
