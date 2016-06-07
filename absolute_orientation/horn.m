% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [R, t, s, RMSE] = horn(A, B)
%% Discription
% HORN implements the algorithm for absolute orientation given by Berthold
% K. P. Horn in the article "Closed-form solution of absolute orientation
% using unit quaternions" (1986).
% The input is two sets of points, *A*, and *B*. *A* is the set of point
% that is to be transformed into the same coordinate system as the points
% in *B*.
% The output is the rotation matrix *R*, the translation *t*, and the scale
% factor *s*.
%

%% Initialization

dim = min([size(A, 2), size(B, 2)]);
A = A(:, 1:dim);
B = B(:, 1:dim);

r_to = bsxfun(@minus, B, mean(B));      % Equivilent to r_r
r_from = bsxfun(@minus, A, mean(A));    % Equivilent to r_l

norm = @(x) dot(x, x, 2);

%% Scale factor

s = sqrt(sum(norm(r_to)) / sum(norm(r_from)) );

%% Rotation

M = r_from' * r_to;
if all(size(M) == [2 2])
    tmp = zeros(3);
    tmp(1:2,1:2) = M;
    M = tmp;
end

S_xx = M(1, 1); S_xy = M(1, 2); S_xz = M(1, 3);
S_yx = M(2, 1); S_yy = M(2, 2); S_yz = M(2, 3);
S_zx = M(3, 1); S_zy = M(3, 2); S_zz = M(3, 3);

N = [S_xx + S_yy + S_zz         S_yz - S_zy         S_zx - S_xz         S_xy - S_yx; ...
        S_yz - S_zy         S_xx - S_yy - S_zz      S_xy + S_yx         S_zx + S_xz; ...
        S_zx - S_xz             S_xy + S_yx     -S_xx + S_yy - S_zz     S_yz + S_zy;...
        S_xy - S_yx             S_zx + S_xz         S_yz + S_zy     -S_xx - S_yy - S_zz];

[V, D] = eig(N);
e = D(1:size(D, 1) + 1: end);  % Extract the eigen values.

[~, I] = max(e);
q = V(:, I);

R = quat2rotmat(q);
R = R(1:dim, 1:dim);

%% Translation

t = bsxfun(@minus, mean(B)', s * R * mean(A)');

%% Root mean square error

RMSE = rmse(B, A, @(x) transform_points(x, R, t, s));

end

function R = quat2rotmat(q)
q_0 = q(1); q_x = q(2); q_y = q(3); q_z = q(4);

R = [q_0^2 + q_x^2 - q_y^2 - q_z^2        2* (q_x *q_y - q_0 * q_z)     2 * (q_x * q_z + q_0 * q_y); ...
      2 * (q_y * q_x + q_0 * q_z)       q_0^2 - q_x^2 + q_y^2 - q_z^2   2 * (q_y * q_z - q_0 * q_x); ...
      2 * (q_z * q_x - q_0 * q_y)       2 * (q_z * q_y + q_0 * q_x)         q_0^2 - q_x^2 - q_y^2 + q_z^2];
% Q = [q_0 -q_x -q_y -q_z; ...
%      q_x  q_0 -q_z  q_y;...
%      q_y  q_z  q_0 -q_x;...
%      q_z -q_y  q_x  q_0];
%
%  Q_bar = [q_0 -q_x -q_y -q_z; ...
%           q_x  q_0  q_z -q_y;...
%           q_y -q_z  q_0  q_x;...
%           q_z  q_y -q_x  q_0];
% R = Q_bar' * Q;
% R = R(2:end, 2:end);
end
