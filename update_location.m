% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function location = update_location(absolute_location, sub_location)
%% Discription

%% Initilaization

dim = size(sub_location);
location = zeros(dim);


%% Updating locations

n = dim(1);

for i = 1:n
    x_min = absolute_location(1);
    y_min = absolute_location(3);
    
    x_sub = sub_location(i, 1:2) - 1;
    y_sub = sub_location(i, 3:4) - 1;
    % - 1 is because MATLAB is 1-indexed, and therefor would add one place
    % to the location. e.g. the area is the same as it was before.
    
    location(i, :) = [x_min + x_sub, y_min + y_sub];
end

end
