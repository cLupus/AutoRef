% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function write_world_file(path, ST)
%% Discription
% WRITE_WORLD_FILE writes the world file (*.twf, *.jwf, etc.) of the
% orthophoto. The inputs are the path to where to file is to be written,
% along with its name, the Similarity Transform (ST), e.i. how to get from image
% coordinates to world coordinates, and the size of the image, as returned
% from size(orthophoto).

%% Initialization
% Similarity transform parameters, extracted
R = ST{1};
t = ST{2};
s = ST{3};

% Creating a transfomation matrix
n = size(R, 1);
transformation_matrix = eye(4);
transformation_matrix(1:n, 1:n) = R;
transformation_matrix = s * transformation_matrix;
transformation_matrix(1:n, 4) = t;


% Opening the file
fileID = fopen(path, 'w');

% Internal parameter
numer = '%.20f\n';

%% World file contetnt
% Based on the discription from
% http://webhelp.esri.com/arcims/9.3/General/topics/author_world_files.htm.

% upper_left_corner = transform_points([1 1 0], R, t, s);
% x_dist = pdist([transform_points([1 2 0], R, t, s); upper_left_corner]);
% y_dist = pdist([transform_points([2 1 0], R, t, s); upper_left_corner]);

A = transformation_matrix(1, 1);
B = transformation_matrix(1, 2);
C = transformation_matrix(2, 4);
D = transformation_matrix(2, 1);
E = transformation_matrix(2, 2);  % Pixels are downward
F = transformation_matrix(1, 4);

%% Write the content to file

fprintf(fileID, numer, abs(A));
fprintf(fileID, numer, D);
fprintf(fileID, numer, B);
fprintf(fileID, numer, -abs(E));
fprintf(fileID, numer, C);
fprintf(fileID, numer, F);

fclose(fileID);
end
