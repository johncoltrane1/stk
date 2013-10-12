% DISTRIB_STUDENT_CDF ...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>
%
%    This code is very loosely based on Octave's tcdf function:
%       ## Copyright (C) 2013 Julien Bect
%       ## Copyright (C) 2012 Rik Wehbring
%       ## Copyright (C) 1995-2012 Kurt Hornik

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

function [p, q] = distrib_student_cdf (x, nu, mu, sigma)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin > 2,
    x = bsxfun (@minus, x, mu);
end

if nargin > 3,
    x = bsxfun (@rdivide, x, sigma);
end

xx = x .^ 2;
[x, xx, nu] = commonsize (x, xx, nu);

% Return NaN for negative values of nu (or nu == NaN, or x == NaN)
p = nan (size (x));
q = nan (size (x));
k0 = (nu > 0) & (~ isnan (x));

% Gaussian case (nu = +inf)
k_inf = isinf (nu);  k = k0 & k_inf;
[p(k), q(k)] = distrib_normal_cdf (x(k));

k0 = k0 & (~ k_inf);
kp = (x > 0);
kn = k0 & (~ kp);
kp = k0 & kp;
k_big_abs = (xx > nu);

% Student case (nu < +inf) for positive x: compute q first, then p = 1 - q
k = kp & k_big_abs;
q(k) = betainc (nu(k) ./ (nu(k) + xx(k)), nu(k)/2, 1/2) / 2;
k = kp & (~ k_big_abs);
q(k) = 0.5 * (1 - betainc (xx(k) ./ (nu(k) + xx(k)), 1/2, nu(k)/2));
p(kp) = 1 - q(kp);

% Student case (nu < +inf) for negative x: compute p first, then q = 1 - p
k = kn & k_big_abs;
p(k) = betainc (nu(k) ./ (nu(k) + xx(k)), nu(k)/2, 1/2) / 2;
k = kn & (~ k_big_abs);
p(k) = 0.5 * (1 - betainc (xx(k) ./ (nu(k) + xx(k)), 1/2, nu(k)/2));
q(kn) = 1 - p(kn);

end % function distrib_student_cdf


%!assert (stk_isequal_tolrel ( ...
%!        distrib_student_cdf ([-1; 0; 1], [1 2], 0, [1 10]), ...
%!        [0.25,                   ... % tcdf ((-1 - 0)/1,  1)
%!         4.6473271920707004e-01; ... % tcdf ((-1 - 0)/10, 2)
%!         0.50,                   ... % tcdf (( 0 - 0)/1,  1)
%!         0.50;                   ... % tcdf (( 0 - 0)/10, 2)
%!         0.75,                   ... % tcdf (( 1 - 0)/1,  1)
%!         5.3526728079292996e-01  ... % tcdf (( 1 - 0)/10, 2)
%!        ], eps))

%!test
%! [p, q] = distrib_student_cdf (1e10, 2);
%! assert (isequal (p, 1.0));
%! assert (stk_isequal_tolrel (q, 4.999999999999999999925e-21, 10 * eps));

%!assert (isequal (distrib_student_cdf (0.0, 1), 0.5));
%!assert (isequal (distrib_student_cdf (inf, 1), 1.0));
%!assert (isequal (distrib_student_cdf (-inf, 1), 0.0));
%!assert (isnan   (distrib_student_cdf (nan, 1)));
