% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function res = mahal_dist(Y, X, m)
%% Disctiption
% MAHAL_DIST runs the bulit in function mahal for an image, instead of just
% an array of points. X is the reference sample, while Y is the points to
% whish we wish to get the distances.
% If the input Y is an image, the output will be an image of distances.
% This should hopefully be faster on larger data than using the mahalanobis
% distance per element.

%% Creating the function
img_size = size(Y);
if img_size(2) == 3 && size(img_size, 2) == 2
    res = mahal(Y, X);
elseif nargin == 2
    res = mahal(reshape(Y, [prod(img_size(1:2)), 3]), X);
    res = reshape(res, [img_size(1), img_size(2)]);
else
    % It is assumed that X is the invers of the covariance matrix
    % and that m is the mean
    val = reshape(Y, [img_size(1) * img_size(2), img_size(3)]);
    res = sum((bsxfun(@minus, val, m) * X) .* bsxfun(@minus, val, m),2);
    res = reshape(res, [img_size(1), img_size(2)]);
end

end
