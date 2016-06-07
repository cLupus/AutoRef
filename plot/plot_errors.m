% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function plot_errors(CM, names, ST, write_text)

image_points = CM(:, 1:end/2);
gcps = CM(:, end/2 + 1:end);

estimated = transform_points(image_points, ST);

diff = bsxfun(@minus, estimated, gcps);

scaling_factor_axis = 1.00005;

%% Errors in location
figure;
quiver(gcps(:,2), gcps(:, 1), diff(:,2), diff(:,1), 0.5);
title('Errors in location of ground control points');
xlabel('Easting');
ylabel('Northing');

grid on
hold on
for i = 1:size(gcps(:,1))
    diff_vec = [ diff(i, 1) diff(i, 2)] / sqrt(diff(i, 1)^2 + diff(i, 2)^2) * 5;
    text(gcps(i, 2) - diff_vec(2), gcps(i,1 ) - diff_vec(1), names{i}, 'HorizontalAlignment', 'center');
    plot(gcps(i, 2), gcps(i, 1), 'b.');
end

ax1 = gca;
set(ax1,'box','off')  %// here you can basically decide whether you like ticks on
                      %// top and on the right side or not

%// new white bounding box on top
ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top');

axis equal
%xlim ([min(gcps(:, 2))/scaling_factor_axis max(gcps(:, 2) * scaling_factor_axis)]);

%% Print errors in location
if nargin == 4 && write_text
    mag = sqrt(sum(diff(:, 1:2)'.^2));
    [val_max, I_max] = max(mag);
    [val_min, I_min] = min(mag);
    fprintf('The largest error in location is %f meters, and occur at the point %s\n', val_max, names{I_max});
    fprintf('The smallest error in location is %f meters, and occur at the point %s\n', val_min, names{I_min});
end

%% Plot errors in height
if size(CM, 2) == 6
    figure;
    quiver(gcps(:,2), gcps(:, 1), zeros(size(diff, 1), 1), diff(:, 3), .4);
    title('Errors in height of ground control points');
    xlabel('Easting');
    ylabel('Northing');
    
    grid on
    hold on
    
    for i = 1:size(gcps(:,1))
        diff_vec = diff(i, 3) / abs(diff(i ,3)) * 5;
        text(gcps(i, 2), gcps(i,1 ) - diff_vec, names{i}, 'HorizontalAlignment', 'center');
        plot(gcps(i, 2), gcps(i, 1), 'b.');
    end
    
    ax1 = gca;
    set(ax1,'box','off')  %// here you can basically decide whether you like ticks on
                          %// top and on the right side or not

    %// new white bounding box on top
    ax2 = axes('Position', get(ax1, 'Position'),'Color','none');
    set(ax2,'XTick',[],'YTick',[],'XColor','w','YColor','w','box','on','layer','top');
    
    axis equal
    %xlim ([min(gcps(:, 2))/scaling_factor_axis max(gcps(:, 2) * scaling_factor_axis)]);
    
    %% Print errors in elevation
    if nargin == 4 && write_text
        mag = abs(diff(:, 3));
        [val_max, I_max] = max(mag);
        [val_min, I_min] = min(mag);
        fprintf('The largest error in elevation is %f meters, and occur at the point %s\n', val_max, names{I_max});
        fprintf('The smallest error in elevation is %f meters, and occur at the point %s\n', val_min, names{I_min});
        
        mag = sqrt(sum(diff'.^2));
        [val_max, I_max] = max(mag);
        [val_min, I_min] = min(mag);
        fprintf('The largest total error is %f meters, and occur at the point %s\n', val_max, names{I_max});
        fprintf('The smallest total error is %f meters, and occur at the point %s\n', val_min, names{I_min});
    end
end

end
