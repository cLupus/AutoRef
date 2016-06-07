% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [H, HH, SU] = test_absori(CM, n)

algorithms = {'Horn', 'HornHilden', 'ShinjiUmeyama'};

n_alg = numel(algorithms);

tmp = cell(n, 3, 3);

dim = size(CM, 2) / 2;
image  = CM(:, 1:dim);
target = CM(:, dim + 1: 2*dim);

for i = 1:n
    for j = 1:n_alg
      [CM_res, ST, rmse]= match_gcps(CM(:,1:3), CM(:,4:6), 'GetOptimal', true, 'MinimumMatches', 7, 'OrientationAlgorithm', algorithms{j});
      tmp(i, :, j) = {CM_res, ST, rmse};
    end
end

H  = tmp(:, :, 1);  % Horn
HH = tmp(:, :, 2);  % Horn-Hilden
SU = tmp(:, :, 3);  % Shinji-Umeyama

end
