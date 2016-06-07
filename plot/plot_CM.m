% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function plot_CM( CM )
%% Discription
% PLOT_CM takes a candidate matching and plots two scatterplots with the
% lables of each points. Usefull for checking that candidates matches.

%%
n = size(CM, 1);

subplot(1, 2, 1);
scatter(CM(:, 1), CM(:, 2), 'bx');
for i = 1:n
    text(CM(i, 1), CM(i, 2), num2str(i));
end
xlabel('x-axis of image');
ylabel('y-axis of image');
title('The mathced points from the image');

subplot(1, 2, 2);
scatter(CM(:, 4), CM(:, 3), 'bx');
for i = 1:n
    text(CM(i, 4), CM(i, 3), num2str(i));
end
xlabel('Easting');
ylabel('Northing');
title('The mathced points from the set of ground control points');


end
