% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function transformed = transform_points(p, R, t, c)

if nargin == 2
    [R, t, c] = extract_parameters_from_similarity_transform(R);
end

if size(R, 1) == 2
    p = p(:,1:2);
end

transformed = bsxfun(@plus, t, c * R * p')';

end
