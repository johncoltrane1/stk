% STK_FILLDIST_DISCRETIZED computes the (discrete) fill distance of a set of points
%
% CALL: D = stk_filldist_discretized(X, Y)
%
%    computes the fill distance D of X using the "test set" Y. More
%    precisely, if X is an n x d matrix and Y an m x d matrix, then
%
%       D = max_{1 <= j <= m} min_{1 <= i <= n} norm(X(i,:) - Y(j,:)),
%
%    where norm(.) denotes the Euclidean norm in R^d. The fill distance
%    is also known as the "maximin" distance.
%
% CALL: [D, ARGMAX] = stk_filldist_discretized(X, Y)
%
%    also returns the value ARGMAX of the index j for which the maximum
%    is obtained. (If the maximum is obtained for several values of j,
%    the smallest is returned.)
%
% See also: stk_dist, stk_mindist

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Author: Julien Bect <julien.bect@supelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function fd = stk_filldist_discretized(x, y)

stk_narginchk(2, 2);

if isstruct(x), x = x.a; end
if isstruct(y), y = y.a; end

% call MEX-file
fd = stk_filldist_discr_mex(x, y);

end % function stk_filldist_discretized


%%
% Two non-empty matrices are expected as input arguments

%!error stk_filldist_discretized(0.0)            % incorrect nb of arguments
%!error stk_filldist_discretized(0.0, 0.0, pi)   % incorrect nb of arguments
%!error stk_filldist_discretized(0.0, [])        % second arg is empty
%!error stk_filldist_discretized([], 0.0)        % first arg is empty


%%
% Check that ".a" structures are accepted

%!test
%! d = 3; x = rand(7, d); y = rand(20, d);
%! fd1 = stk_filldist_discretized(x, y);
%! fd2 = stk_filldist_discretized(struct('a', x), struct('a', y));
%! assert(stk_isequal_tolabs(fd1, fd2));

%%
% fd = 0 if X = Y

%!test
%! n = 5;
%! for dim = 1:10,
%!     x = rand(n, dim);
%!     fd = stk_filldist_discretized(x, x);
%!     assert(stk_isequal_tolabs(fd, 0.0));
%! end

%%
% fd = norm if nx = ny = 1

%!test
%! for dim = 1:10,
%!     x = rand(1, dim);
%!     y = rand(1, dim);
%!     fd = stk_filldist_discretized(x, y);
%!     assert(stk_isequal_tolabs(fd, norm(x - y)));
%! end

%%
% Filldist = max(dist) if ny = 1

%!test
%! n = 4;
%! for dim = 2:10,
%!     x = zeros(n, dim);
%!     y = rand(1, dim);
%!     fd = stk_filldist_discretized(x, y);
%!     assert(stk_isequal_tolabs(fd, max(stk_dist(x, y))));
%! end

%%
% One point in the middle of [0; 1]^d

% FIXME: stk_filldist_discretized() does not accept .a structure right now

% %!test
% %! for dim = [1 3 6],
% %!     x  = 0.5 * ones(1, dim);
% %!     y  = stk_sampling_regulargrid(2^dim, dim);  % [0; 1]^d is the default box
% %!     fd = stk_filldist_discretized(x, y);
% %!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
% %! end