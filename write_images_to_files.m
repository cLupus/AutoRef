% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function write_images_to_files(imgs, path, is_lab)

extension = '.png';
n_img = numel(imgs);

if path(end) ~= '\' && path(end) ~= '/'
    path = strcat(path, '\');
end

for i = 1:n_img
    if is_lab
        img = lab2rgb(imgs{i});
    else
        img = imgs{i};
    end
    imwrite(img, strcat(path, num2str(i), extension));
end

end
