% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function num = num_regions( BW )
%% Discription
% NUM_REGIONS computes the number of seperated regions there are in the
% given binary image.

%% Compute number of regions
CC = bwconncomp(BW, 8);
num = CC.NumObjects;

end
