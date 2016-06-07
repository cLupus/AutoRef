% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function plot_property_fun(binimg, properies, fun)

imshow(binimg);
hold on;

if ~islogical(binimg)
    % Makes sure the image is binary, or else regionprops does not work.
    binimg = binimg == 1;
end

vars = properies;
vars{end + 1} = 'Centroid';

res = regionprops(binimg, vars);

for i = 1:numel(res)
    field_vals = cell(numel(properies), 1);
    
    element = res(i);
    
    for j = 1:numel(properies)
        field_vals(j) = {element.(cell2mat(properies(j)))};
    end
        
    centroid = element.Centroid;
    x = centroid(1);
    y = centroid(2);
    feature = fun(field_vals{:});
    
    text(x, y, num2str(feature), 'HorizontalAlignment','left', 'Color', 'red');
    
end
    
end