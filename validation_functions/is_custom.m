% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function output_arg = is_custom( input_arg )
%% Discripption
% Checks if the given input is a valid custom input for
% "prune_morphology.m". It must contain which properties it should
% extract from regionprops, a function to act on these properties, and an
% interval for which the output from the function should be within in order
% to be considered OK. If the field 'Outside' is set to true, the oposite
% is true.

%% Check structure
if ~isstruct(input_arg)
    output_arg = false;
    return
end

if isstruct(input_arg) && isempty(input_arg)
    output_arg = true;
    return
end

output_arg = any(strcmp('Interval', fieldnames(input_arg))) && ...
             any(strcmp('Properties', fieldnames(input_arg))) && ...
             any(strcmp('Function', fieldnames(input_arg))) && ...
             any(strcmp('NecessaryProperties', fieldnames(input_arg))) && ...
             any(strcmp('Mode', fieldnames(input_arg)));
if ~output_arg
    return
end


%% Check content
if any(strcmp('Outside', fieldnames(input_arg)))
    output_arg = islogical(input_arg.Outside);
    return
end

output_arg = is_interval(input_arg.Interval) && ...
             is_properties(input_arg.Properties) && ...
             is_function(input_arg.Function) && ...
             is_properties(input_arg.NecessaryProperties) && ...
             is_valid_mode(input_arg.Mode);

end
