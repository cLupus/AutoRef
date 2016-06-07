% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [PD_band1, PD_band2, PD_band3] = get_most_likely_distribution(data)
    
    PD = allfitdist(data(:, 1));
    PD_band1 = PD(1);
    
    PD = allfitdist(data(:, 2));
    PD_band2 = PD(1);
    
    PD = allfitdist(data(:, 3));
    PD_band3 = PD(1);
end
