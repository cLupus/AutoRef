% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function none = plot_hist_and_pdf(data, pdf)

size_data = numelements(data);

[n,x] = hist(data, 50);
bar(x, n/ size_data /diff(x(1:2)))
hold on
plot(x,pdf(x),'r')
end