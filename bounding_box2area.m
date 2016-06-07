% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function area = bounding_box2area( BB )
%% BOUNDING_BOX2AREA: Calculates the area of a given bounding box

%% Initializing
if iscell(BB)
    BB = BB{:};
end

[x_min, x_max, y_min, y_max] = bounding_box2limits(BB);


%% Calculate area

area = (x_max - x_min + 1) * (y_max - y_min + 1);

end
