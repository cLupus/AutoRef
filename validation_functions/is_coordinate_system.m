% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_coordinate_system( input_arg )
%% Discription
% IS_COORDINATE_SYSTEM checks if the coordinate system of a point set is
% valid.

%% Check
output_arg = strcmpi(input_arg, 'xy') || ...    % cartesian x-y
             strcmpi(input_arg, 'yx') || ...    % cartesian y-x
             strcmpi(input_arg, 'ne') || ...    % Projection Northing-Easting
             strcmpi(input_arg, 'en');          % Projection Easting-Northing

end
