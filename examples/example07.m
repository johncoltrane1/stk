% Example 07 : illustration of the Matern family of correlation functions
% =======================================================================

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version:   1.0
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%

%% List of correlation functions

% Parameters used as initial values for stk_param_estim()
SIGMA2 = 1.0;  % variance parameter
RHO1   = 1.0;  % scale (range) parameter

% kriging with constant mean function ("ordinary kriging)
list_cov = {...
    'Matern 1.0', 'stk_materncov_iso',   [log(SIGMA2), log(0.5), log(1/RHO1)]'; ...
    'Matern 3/2', 'stk_materncov32_iso', [log(SIGMA2), log(1/RHO1)]';           ...
    'Matern 5/2', 'stk_materncov52_iso', [log(SIGMA2), log(1/RHO1)]';            ...
    'Matern 8.0', 'stk_materncov_iso',   [log(SIGMA2), log(8.0), log(1/RHO1)]'; ...
    };

NB_COVARIANCE_FUNCTIONS = size(list_cov, 1);

%% visualisation

x1 = struct('a', 0.0);
x2 = stk_sampling_cartesiangrid(1000, 1, [-5; 5]);

col = {'r', 'b', 'g', 'k'}; figure;

for j = 1:NB_COVARIANCE_FUNCTIONS,
    covfun = list_cov{j, 2};
    param = list_cov{j, 3};
    plot(x2.a, feval(covfun, x1, x2, param), 'Color', col{j});
    hold on;
end

xlabel('x');
ylabel('correlation r(x)');
legend(list_cov{:, 1});
title('Some members of the Matern family');
