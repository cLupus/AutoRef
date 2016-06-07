% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [rmse_mat, radius_opt, angle_opt] = find_optimal_parameters(img_coordinates, gcps, min_matches, radius_params, angle_params)
%% Discription
% FIND_OPTIMAL_PARAMETERS tries all the combinations of radius_params
% and angle_params with the function match_gcps in order to find
% the optimal parameters. They are optimal in the sense that they
% gives the lowest root mean square error.

%% Initializing
n = numel(radius_params);
m = numel(angle_params);

dims = min([ size(img_coordinates, 2), size(gcps, 2) ]);
coord = img_coordinates(:, 1:dims);
gcps = gcps(:, 1:dims);

rmse_mat = zeros(n, m);

%% Running
for radius = 1:n
    for angle = 1:m
        [~, ~, e] = match_gcps(coord, gcps(:,1:2), ...
            'ImageTppMode', 'all', ...
            'RadiusThreshold', radius, ...
            'AngleThreshold', angle, ...
            'GetOptimal', true, ...
            'MinimumMatches', min_matches);
        rmse_mat(radius, angle) = e;
    end
end

[radius_idx, angle_idx] = find(rmse_mat == min(rmse_mat(:)));

radius_opt = radius_params(radius_idx);
angle_opt = angle_params(angle_idx);

end
