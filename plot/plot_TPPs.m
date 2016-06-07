% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function plot_TPPs(TPPa, TPPb)
%% Discription
% PLOT_TPPS creates a scatter plot of the two topological point patterns,
% making it easy to compare them.

%% Plot

[x,y] = pol2cart(TPPa(:,2), TPPa(:,1));
scatter(x,y);
hold on
[x,y] = pol2cart(TPPb(:,2), TPPb(:,1));
scatter(x,y, 'x');


end
