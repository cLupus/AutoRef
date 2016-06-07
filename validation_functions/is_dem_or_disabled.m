% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_dem_or_disabled( input_arg )
%% Discription
% IS_DEM_OR_DISABLED checks if the input argument is a digital elivation
% model, or disabled, i.e. false.

%% Check
output_arg = (islogical(input_arg) && input_arg == false) || ...
             ischar(input_arg) || ismatrix(input_arg);
end
