% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function none = plot_nonparametric(data)
% Inspired from https://se.mathworks.com/help/stats/kernel-distribution.html

hname = {'normal' 'epanechnikov' 'box' 'triangle'};
colors = {'r' 'b' 'g' 'm'};
lines = {'-','-.','--',':'};

%data = R;

%figure
h = histogram(data);
limits = h.BinLimits;
max_val = max(h.Values);

for j=1:4
    pd = fitdist(data,'kernel','Kernel',hname{j});
    x = limits(1):0.001:limits(2);
    y = pd.pdf(x);
    plot(x,y / max(y) * max_val, 'Color', colors{j}, 'LineStyle', lines{j})
    hold on;
end
legend(hname{:}, 'Location', 'NorthWest');
histogram(data);
hold off

end
