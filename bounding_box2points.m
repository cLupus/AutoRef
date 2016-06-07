% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function BB_points = bounding_box2points(BB)
%% Description
% A simple function that converts a list of bounding boxes that are defined
% as [x_min x_max y_min y_max] to a list of points of the form
% x_min y_min
% x_min y_max
% x_max y_min
% x_max y_max

%% 
BB_points = [BB(:,1) BB(:,3) ;
             BB(:,1) BB(:,4) ;
             BB(:,2) BB(:,3) ;
             BB(:,2) BB(:, 4)];
end
