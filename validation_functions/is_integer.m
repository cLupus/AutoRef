% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_integer( input_arg )
%% Discription
% IS_INTEGER checks that the given input is a positive scalar integer.

%% Check
output_arg = mod(input_arg, 1) == 0 && all(size(input_arg) == [1 1]);

end
