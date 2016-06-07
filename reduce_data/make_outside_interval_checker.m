% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function outside = make_outside_interval_checker(min_boundary, max_boundary)
%% Discription
% MAKE_OUTSIDE_INTERVAL_CHECKER creates a function that checjs if a value
% is inside an interval with inclusive, or exclusive bounderies.

%% Initilaizing
if strcmp(min_boundary, 'Exclusive')
    outside_min = @(value, minimum) value <= minimum;
elseif strcmp(min_boundary, 'Inclusive')
    outside_min = @(value, minimum) value < minimum;
else
    error('Not a valid maximum boundary. Use ''Exclusive'' or ''Inclusive''');
end

if strcmp(max_boundary, 'Exclusive')
    outside_max = @(value, maximum) value >= maximum;
elseif strcmp(max_boundary, 'Inclusive')
    outside_max = @(value, maximum) value > maximum;
else
    error('Not a valid maximum boundary. Use ''Exclusive'' or ''Inclusive''');
end

%% Create function
outside = @(value, minimum, maximum) outside_min(value, minimum) || ...
                                     outside_max(value, maximum);
end
