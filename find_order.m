% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function I = find_order(A, B)
%% Discription
% FIND_ORDER find where each element of A is in B.

%% Find matches
n = size(A, 1);

I = zeros(n, 1);

for i = 1:n
    if isnumeric(A) && isnumeric(B)
        match = bsxfun(@eq, B, A(i,:));
    elseif ischar(A{1}) && ischar(B{1})
        match = strcmpi(B, A{i});
    end
    I(i) = find(match(:,1));
end

end
