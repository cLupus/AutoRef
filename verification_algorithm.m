% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function [CM, ST, RMSE] = verification_algorithm( CCM, alg, use_horn_scale )
%% Discription
% VERIFICATION_ALGORITH implements the verification lagorithm given by Yan
% Li & Ronald Briggs in "Automated Georeferencing Based on Topological
% Point Pattern Matching".
% It takes as input a Collection of Candidate Matchings (the outpu from
% "match_gcps.m", which implements the matching algorithm in the same
% paper.
% The output is the best Candidate Matching along with is Similarity
% Transfom, i.e. the parameters to apply to the image the points was
% extracted from in order to georeference it.
%
% The option *alg* chooses the algorithm to be used when computing the
% optimal absolute orientation. This option is only applicable when
% the 'GetOptimal'-flag is set to true. The valid options are
% 'ShinjiUmeyama', 'Horn', and 'HornHilden'.
% Default is 'Horn'.


i_p = inputParser;
i_p.FunctionName = 'VERIFICATION_ALGORITHM';

% Requiered
i_p.addRequired('CCM', @is_candidate_point_lists);

% Optional
i_p.addOptional('OrientationAlgorithm', 'Horn', @is_valid_orientation_algorithm);

i_p.parse(CCM, alg);

%% Deal with the input
input = i_p.Results;

algorithm = input.OrientationAlgorithm;

%% Initialization

n = size(CCM, 1);
RMSEs = zeros(n, 1);
parameters = cell(n, 1);
%% Compute RMSE

for i = 1:n
    CM = CCM{i};
    m = size(CM, 2) / 2;
    A = CM(:, 1:m);
    B = CM(:, m + 1: 2 * m);
    if strcmpi(algorithm, 'ShinjiUmeyama')
        [R, t, c, RMSE] = shinji_umeyama(A, B, use_horn_scale);
    elseif strcmpi(algorithm, 'HornHilden')
        [R, t, c, RMSE] = horn_hilden(A, B);
    elseif strcmpi(algorithm, 'Horn')
        [R, t, c, RMSE] = horn(A, B);
    else
        error('Invalid choise of algorithm');
    end
    parameters{i} = {real(R), real(t), c};
    RMSEs(i) = real(RMSE);
end

[RMSE, I] = min(RMSEs);
CM = CCM{I, :};
ST = parameters{I, :};

end
