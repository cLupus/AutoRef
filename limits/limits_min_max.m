% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function res = limits_min_max(vals, p)
%% Discription
% Creates a matrix of minimum and maximum values if p is not given. If p is
% between 0 - 1, then the function will return the p and 1 - p quantiles of
% the data for each band.

%% Initializatinon
if ~exist('p', 'var')
    p = 0;
elseif p > 1
    p = 1;
elseif p < 0
    p = 0;
end

size_vals = size(vals);
num_bands = size_vals(2);
res = zeros(num_bands, 2);

%% Getting values
for i = 1:num_bands
    % A little MATLAB hack to get the values into a 1 x 2 vector.
    q = quantile(vals(:,i), [p, 1 - p]);
    res(i, :) = [q(1), q(2)];
end
