% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function reflected_points = mirror(points, direction)
%% Discription
% REFLECT reflects all the points in the set *points* about a line trough
% the centre of the points. The direction of the line the points are to be
% reflected about can either be 'Horizontal', or 'Vertical'.

%%
means = mean(points);
r = bsxfun(@minus, points, means);

if strcmpi(direction, 'Horizontal')
    r = [r(:, 1) r(:,2) * -1];
elseif strcmpi(direction, 'Vertical')
    r = [r(:, 1) * -1 r(:,2)];
end
if size(points, 2) == 3
    r = [r, points(:, 3)];
end

reflected_points = bsxfun(@plus, r, means);

end
