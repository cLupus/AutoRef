% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_interval_or_disabled( input_arg )
%% Discription
% Checks that the given input is an interval, i.e. there are only two
% elements in the vector, and that the first element is smaller than the
% last element, or if it is disabled, i.e. false. If it is set to be true,
% it will later be assumed that the default values are to be used.

%% Check
output_arg = is_interval(input_arg) || islogical(input_arg);

end
