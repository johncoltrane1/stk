% STK_PREDICT_LEAVEONEOUT computes LOO predictions and residuals
%
% CALL: LOO_PRED = stk_predict_leaveoneout (M_prior, xi, zi)
%
% CALL: [LOO_PRED, LOO_RES] = stk_predict_leaveoneout (M_prior, xi, zi)
%
% See also stk_example_kb10

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%
%    Author:  Julien Bect      <julien.bect@centralesupelec.fr>
%             Stefano Duhamel  <stefano.duhamel@supelec.fr>

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

function varargout = stk_predict_leaveoneout (M_prior, xi, zi)

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

M_post = stk_model_gpposterior (M_prior, xi, zi);

varargout = cell (1, max (1, nargout));
[varargout{:}] = stk_predict_leaveoneout (M_post);

end % function


%!test  % heteroscedastic noise case
%! x_obs = stk_sampling_regulargrid (20, 1, [0; 2*pi]);
%! z_obs = stk_feval (@sin, x_obs);
%! model = stk_model ('stk_materncov32_iso');
%! model.param = log ([1; 5]);
%! model.lognoisevariance = linspace (0.1, 1, 20);
%! [loo_pred, loo_res] = stk_predict_leaveoneout (model, x_obs, z_obs);
