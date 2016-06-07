% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function extract_all_gcp(img, path, coordinates, area)
if ischar(img)
    img = imread(img);
end


for i = 1:max(size(coordinates))
    name = strcat(path, 'P', num2str(i), '.png');
    extract_area_around_point(img, coordinates(i,:), area, name);
end

end
