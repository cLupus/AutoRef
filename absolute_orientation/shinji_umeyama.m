% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [R, t, s, RMSE] = shinji_umeyama(A, B, use_horn_scale)
%% Discription
% SHINJI_UMEYAMA implements the algorithm described by Shinji & Umeyama in
% their article "Least-Squares Estimation of Transformation Parameters
% Betweeen Two Point Patterns.
% It takes as input two n x m matrices of points, and matches the points in
% A to the points in B.
% It then gives the optimal Rotation matrix (R), along with the optimal
% translation vector (t) and the optimal scaling factor (s).
% This method constricts the avilable solution space to rotations,
% translations, and scaling. This method does NOT considere reflection.

%% Error checking
if ~all(size(A) == size(B))
    error('The matrices are of different size. They MUST BOTH be of the size n x m');
end

%% Threshold
% Because floating point numbers are not entielry accurate.

thresh = 1e-5;

%% Decomposition
mu_A = mean(A);
mu_B = mean(B);

n = size(A, 2);

covariance_matrix = 1 / n * bsxfun(@minus, B, mu_B)' * bsxfun(@minus, A, mu_A);

[U, D, V] = svd(covariance_matrix);

n = size(A, 1);
m = size(A, 2);

d = det(U) * det(V);
if sign(d) == 1 && abs(d - 1) < thresh
    S = eye(m);
elseif sign(d) == -1 && abs(d + 1) < thresh
    S = eye(m);
    S(end, end) = -1;
else
    error('There was an error with the decomposition: det(U) * det(V) ~= [-1, 1]');
end

%% Compute statistics
mu_a = mean(A)';
mu_b = mean(B)';

variance_a = 1 / n * sum(sum(bsxfun(@minus,A', mu_a)'.^2));
variance_b = 1 / n * sum(sum(bsxfun(@minus,B', mu_b)'.^2));


%% Compute outputs
R = U * S * V';
s = 1 / variance_a * trace( D * S);
if nargin == 3 && use_horn_scale
    s = sqrt(variance_b/variance_a);
end
t = mu_b - s * R * mu_a;

RMSE = sqrt(1 / n * sum(sum((B' - bsxfun(@plus, s * R * A', t)).^2)));

end
