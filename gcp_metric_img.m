% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function measures = gcp_metric_img(binimg)
neighbourhood = ones(3);

[~, ~, area, BB] = find_centers_of_pointclusters(binimg, neighbourhood);
measures = gcp_metric(area, BB);
end