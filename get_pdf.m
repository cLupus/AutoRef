% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [pdf, cdf] = get_pdf(PD, i)
%% Discription
% A function to extract the i-th probability denisity function and the
% cummulative distributiuon function of the collection PD. If i is not
% given, the pdf will be extracted from PD, as it is assumed that PD is a
% single element.

%% Check number of parameters
if nargin == 2
    Dist = PD(i);
else
    Dist = PD;
end

%% Get the probability density function
if isstruct(Dist)
    params = num2cell(Dist.Params);
    Dist = makedist(Dist.DistName, params{:});
end
pdf = @(x) Dist.pdf(x);
cdf = @(x) Dist.cdf(x);

end
