% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function reduced = remove_empty_cells(cellarray)
%% Discription
% REMOVE_EMPTY_CELLS removes all empty cells from a cell array.

%% 
reduced = cellarray(~cellfun('isempty',cellarray));

end
