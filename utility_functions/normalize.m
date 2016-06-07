% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = normalize( input_arg )
%% Discription
% NORMALIZE normalizes the input in a linear fashion.

%% Normalize the data
output_arg = (input_arg - min(input_arg(:))) / (max(input_arg(:)) - min(input_arg(:)));

end
