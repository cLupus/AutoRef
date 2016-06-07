% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function location = find_centra(distance_images, locations)

n_img = numel(distance_images);
location = zeros(n_img, 2);

for i = 1:n_img
    dist_img = distance_images{i};
    [row, col] = find(dist_img == min(dist_img(:)));
    if numel(row) >= 2 || numel(col) >= 2
        row = round(mean(row));
        col = round(mean(col));
    end
    bounding_box = locations(i, :);
    x_min = bounding_box(1);
    y_min = bounding_box(3);
    location(i, :) = [x_min + col, y_min + row];
end

end
