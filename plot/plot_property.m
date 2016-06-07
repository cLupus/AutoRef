% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function none = plot_property(binimg, property)

imshow(binimg);
hold on;

res = regionprops(binimg, 'Centroid', property);

for i = 1:numel(res)
    element = res(i);
    centroid = element.Centroid;
    x = centroid(1);
    y = centroid(2);
    feature = element.(property);
    
    text(x, y, num2str(feature), 'HorizontalAlignment','left', 'Color', 'red');
    
end
    
end