% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function res = limits(values, mode, opt)
%% Discrition
% This is a function that gathers the limits_min_max and limits_mean_std
% functions into one umbrella function.
% The values are a collection of values (a matrix) where each column
% represents a sepearate band. The mode specifies how the limits are to be
% computed: 'min-max' or 'mean-std'. The opt argument specifies any
% auxillary information that is requiered. For min-max, it is the
% percentile of quantiles to be used. 0 or 1 gives min/max, while for
% 'mean-std' the option is the weight to be given to the standard
% deviation.

%% Initializing
default = 'min-max';

if nargin < 2
    mode = default;
elseif nargin < 3
    if strcmp(mode, 'min-max')
        opt = 0;
    elseif strcmp(mode, 'mean-std')
        opt = 1;
    else
        warning(strcat('Invalid mode, using default, (', default, ').'));
    end
end

%% Getting limits

if strcmp(mode, 'min-max')
    res = limits_min_max(values, opt);
elseif strcmp(mode, 'mean-std')
    means = mean(values);
    stds = std(values);
    res = limits_mean_std(means, stds, opt);
else
    res = limits(values, default);
end

end
