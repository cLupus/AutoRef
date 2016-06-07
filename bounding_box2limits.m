% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [x_min, x_max, y_min, y_max] = bounding_box2limits(BB)
%% Discription
% A function that converst the BoundingBox given by regionprops to the
% vector [x_min, x_max, y_min, y_max].
% The output can be a matrix, a vector, or 4 scalars

%% Type checking
if isstruct(BB) && numel(BB) == 1
    BB = BB.BoundingBox;
elseif isstruct(BB)
    error('There are multiple bounding boxes.');
end

%% Extracting values
x_start = BB(1);  % double (start.5000)
y_start = BB(2);  % double (start.5000)

width   = BB(3);  % int
height  = BB(4);  % int

%% Computing the limits
x_min = ceil(x_start);
y_min = ceil(y_start);

x_max = x_min + width - 1;   % The width includes the start
y_max = y_min + height - 1;  % The height includes the start

%% Generating outputs
if nargout <= 1 && numel(BB) == 1
    x_min = [x_min, x_max, y_min, y_max];
end

