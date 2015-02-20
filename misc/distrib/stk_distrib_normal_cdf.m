% STK_DISTRIB_NORMAL_CDF  [STK internal]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function [p, q] = stk_distrib_normal_cdf (z, mu, sigma)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin > 1,
    z = bsxfun (@minus, z, mu);
end

if nargin > 2,
    z = bsxfun (@rdivide, z, sigma);
    k0 = (sigma > 0);
else
    k0 = 1;
end

p = nan (size (z));
q = nan (size (z));

k0 = bsxfun (@and, k0, ~ isnan (z));
kp = (z > 0);
kn = k0 & (~ kp);
kp = k0 & kp;

% Deal with positive values of x: compute q first, then p = 1 - q
q_kp = 0.5 * erfc (0.707106781186547524 * z(kp));
q(kp) = q_kp;
p(kp) = 1 - q_kp;

% Deal with negative values of x: compute p first, then q = 1 - p
p_kn = 0.5 * erfc (- 0.707106781186547524 * z(kn));
p(kn) = p_kn;
q(kn) = 1 - p_kn;

end % function stk_distrib_normal_cdf


%!assert (stk_isequal_tolrel (stk_distrib_normal_cdf ([1; 3], 1, [1 10]),  ...
%!                 [0.5, ...  % normcdf ((1 - 1) / 1)
%!                  0.5; ...  % normcdf ((1 - 1) / 10)
%!                  0.5 * erfc(-sqrt(2)),    ...  % normcdf ((3 - 1) / 1)
%!                  0.5 * erfc(-0.1*sqrt(2)) ...  % normcdf ((3 - 1) / 10)
%!                 ], eps));

%!test
%! [p, q] = stk_distrib_normal_cdf (10);
%! assert (isequal (p, 1.0));
%! assert (stk_isequal_tolrel (q, 7.6198530241604975e-24, eps));

%!assert (isequal (stk_distrib_normal_cdf ( 0.0), 0.5));
%!assert (isequal (stk_distrib_normal_cdf ( inf), 1.0));
%!assert (isequal (stk_distrib_normal_cdf (-inf), 0.0));
%!assert (isnan   (stk_distrib_normal_cdf ( nan)));
%!assert (isnan   (stk_distrib_normal_cdf (0, 0, -1)));
