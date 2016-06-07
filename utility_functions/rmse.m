% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function RMSE = rmse(target, x, fun)

n = size(target, 1);

RMSE = sqrt(1 / n * sum(sum((target - fun(x)).^2)));

end
