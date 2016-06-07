% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [R, t, s, RMSE] = horn_hilden(A, B)
%% Discription
%

%% Initilaization
if size(A, 2) == 2
    A = [A zeros(size(A, 1), 1)];
end

if size(B, 2) == 2
    B = [B zeros(size(B, 1), 1)];
end

%% Scale factor
r_from_mean = mean(A);
r_to_mean   = mean(B);

r_from      = bsxfun(@minus, A, r_from_mean);
r_to        = bsxfun(@minus, B, r_to_mean);

s = sqrt( sum(dot(r_to, r_to, 2)) / sum(dot(r_from, r_from, 2)) );

%% Rotaion

M = r_from' * r_to;

%S = (M' * M)^(1/2);

if rank(M) == 2
    [V, D] = eig(M' * M);
    e = diag(D);
    
    [~, I] = sort(abs(e), 'descend');
    e_1 = e(I(1)); e_2 = e(I(2));
    u_1 = V(:,I(1)); u_2 = V(:,I(2));
    S_plus = 1/sqrt(e_1) .* u_1 * u_1' + 1/sqrt(e_2) .* u_2 * u_2';
    [U_0, ~, V_0] = svd(M * S_plus);
    u_3 = U_0(:, 3); v_3 = V_0(:, 3);
    
    R = M * S_plus + u_3 * v_3';
    if sign(det(R)) == -1
        R = M * S_plus - u_3 * v_3';
    end
else
    R = (M / (sqrtm(M' * M)))';
end
%% Translation
t = r_to_mean' - s * R * r_from_mean';

%% Root mean square error
RMSE = rmse(B, A, @(x) transform_points(x, R, t, s));

end
