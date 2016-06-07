% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [R, t, s] = extract_parameters_from_similarity_transform( ST )
%% Discription
% EXTRACT_PARAMETERS_FROM_SIMILARITY_TRANSFORM extracts the rotational
% matrix R, the translation vector t, and the scale factor s from the
% similarity transform, ST, cell array.
% Usefull when dealing with the results from match_gcps.m, and others.

%% Extraction
R = ST{1};
t = ST{2};
s = ST{3};

end
