% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function p = normpdf_cutoff(x, mu, sigma, low_cutoff, high_cutoff)

p = normpdf(x, mu, sigma);
if p > high_cutoff
    p = 1;
elseif p < low_cutoff
    p = 0;
end
end
