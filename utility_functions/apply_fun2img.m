% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function res = apply_fun2img(fun, image)
%% Discription
% APPLY_FUN2IMG applies the given function to each color of the given
% image, if the image has 3 bands, otherwise, it is assumed that the
% function takes a single column vector as input that has the same size as 
% the number of bands.

%% Error checking
if ~isa(fun, 'function_handle')
    error('The given function is not a function handle');
end

%% Initializing
dims = size(image);

%% Apply function
res = fun(reshape(image, [dims(1) * dims(2), dims(3)]));
res = reshape(res, [dims(1), dims(2)]);

end

