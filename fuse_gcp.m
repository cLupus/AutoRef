% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
img_size = 101;

gcd = zeros(img_size * 4, img_size * 5, 3);
path = 'path-to-images';
ext = '.image-extension';

a = ls(strcat(path, '*', ext));
% a = setdiff(strsplit(a, '\n'), '');
tmp = cell(size(a, 1), 1);
for i = 1:size(a, 1)
    tmp{i} = strtrim(a(i, :));
end
a = tmp;
a = sort_nat(a);  % Sorts in a natural order, i.e. file1, file2, file10
location = '';

for i = 1:max(size(a))
    % Using ls, we get a more natural order than dir, but it gives a single
    % string wich then must be split. The splitting creates a cell array.
    img_path = strcat(path, cell2mat(a(i)));
    img = im2double(imread(img_path));

    r = ceil(i / 5);
    c = mod(i, 5);
    if c == 0
        c = 5;
    end

    start_row = 1 * r + (img_size - 1) * (r - 1);
    end_row = start_row + (img_size - 1);

    start_col = 1 * c + (img_size - 1) * (c - 1);
    end_col = start_col + (img_size - 1);

    gcd(start_row:end_row, start_col:end_col, :) = img;


    parts = strsplit(img_path, '/');
    name = cell2mat(parts(end));
    location = strcat(location, 'Row ', num2str(r), ', Col ', num2str(c),': ', name, ', ');
end

imwrite(gcd, strcat(path, 'gcp.png'));
