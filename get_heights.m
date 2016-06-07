% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function heights = get_heights( dem, points, area )
%% Discription
% GET_HEIGHS takes a digital elevation model and a set of points as input,
% and gives out the heights of each point in order. Area is an optinal
% argument that specifies the side length of the sample area for each
% point. The defalut is 1.
% The dem argument can be either the full elevation model, or it can be the
% path to the model.

%% Initiliazation
if nargin == 2
    area = 1;
end

if ischar(dem)
    dem = imread(dem);
end

n = size(points, 1);
heights = zeros(n, 1);

%%

height_cells = get_area(dem, points, round(sqrt(area) / 2 - 1));
for i = 1:n
    height_area = height_cells{i};
    heights(i) = mean(height_area(:));
end

end
