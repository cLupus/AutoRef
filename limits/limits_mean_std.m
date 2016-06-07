% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function res = limits_mean_std(means, stds, weights)
%% Description
% A function that creates minimum and maximum values for each of the bands.
% It gives a matrix with minimum and maximum values. The paramters is
% means, which is a vector of means for each band, while stds is a vector
% for the standard deviation of each band, while weights is a scalar or
% vector of weights for the standard deviation.
% The result will be in the form
%     mean(1) - wheights(1) * stds(1), means(1) + wheights(1) * stds(1)
%     mean(2) - wheights(2) * stds(2), means(2) + wheights(2) * stds(2)
%                                  .
%                                  .
%                                  .

%% Checking consistency
if ~(isvector(means) && isvector(stds) && ...
        (isvector(weights) || isscalar(weights)))
    error('The means, standard deviations, and the weights are not vecotrs, or weights is not a scalar');
elseif numel(means) ~= numel(stds)
    error('The number of means and standard deviations is not the same');
elseif numel(means) ~= numel(weights) && numel(weights) ~= 1
    error('The number of weights is not the same as the means and standard deviations, and weights is not a scalar');
end

%% Initializing
res = zeros(numel(means), 2);
if isscalar(weights)
    temp = zeros(size(means));
    temp(:) = weights;
    weights = temp;
end

for i = 1:numel(means)
    variance = weights(i) * stds(i);    
    res(i,:) = [means(i) - variance, means(i) + variance];
end
