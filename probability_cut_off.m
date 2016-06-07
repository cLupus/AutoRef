% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function x = probability_cut_off(p)

if p > 1
    x = 1;
elseif p < 0
    x = 0;
else
    x = p;
end
end
