% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_sample_data_or_disabled( input_arg )
%% Discription
% IS_SAMPLE-DATA_OR_DISABLED checks that the input data is a valid sample
% of RGB vales, or a path, or disabled.

%% Check
output_arg = (isnumeric(input_arg) && size(input_arg, 2) == 3) || ...
              ischar(input_arg) || ...
              (islogical(input_arg) && input_arg == false);

end
