% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function varargout = invert(varargin)
%% Discription
% INVERT inverts the the rotation matrix, translation and the scaling
% factor. It can also take a set of similarity transform, ST = {R, t, s}.
%
% Uses:
% ST = invert(ST)
% ST = invert(R, t, s)
% [R, t, s] = invert(ST)
% [R, t, s] = invert(R, t, s)

%% Initialization
if nargin == 1
    ST = varargin{1};
    R = ST{1};
    s = ST{3};
    t = ST{2};
elseif nargin == 3
    R = varargin{1};
    t = varargin{2};
    s = varargin{3};
end

%% Inversion

R_inv = R \ eye(size(R));
c_inv = 1 / s;
t_inv = - 1 / s * R_inv * t;

if nargout <= 1
    varargout{1} = {R_inv, t_inv, c_inv};
else
    varargout{1} = R_inv;
    varargout{2} = t_inv;
    varargout{3} = c_inv;
end

end
