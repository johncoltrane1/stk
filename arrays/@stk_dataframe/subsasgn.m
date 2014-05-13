% SUBSASGN [overloaded base function]

% Copyright Notice
%
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

function x = subsasgn(x, idx, val)

if ~ isa (x, 'stk_dataframe')
    if isempty (x)
        % this is required to support B(idx) = D if B does not exist and D is
        % an stk_dataframe (which, in turn, is required to make repmat work...)
        x_data = subsasgn ([], idx, val.data);
        x = stk_dataframe (x_data);
    else
        % we're assigning a dataframe (val) to something else
        x = subsasgn(x, idx, val.data);
    end
    return
end

if all (builtin ('size', x) == 0)
    % This happens in Octave 3.2.x when doing B(idx) = D if B does not exist and
    % D is an stk_dataframe. In this case, x is a 0x0 stk_dataframe object.
    x = stk_dataframe ();
end

switch idx(1).type
    
    case '()'
        
        if length(idx) ~= 1
            
            stk_error('Illegal indexing.', 'IllegalIndexing');
            
        else % ok, only one level of indexing
            
            [n, d] = size (x.data);
            
            % one or two indices, but not more than that
            L = length (idx(1).subs);
            if L > 2
                stk_error('Illegal indexing.', 'IllegalIndexing');
            end
            
            val = double (val);
            
            if ~ isempty (val)  % assignment
                
                x.data = subsasgn(x.data, idx, val);
                
                [n1, d1] = size(x.data);
                if (n1 > n) && ~ isempty (x.rownames)
                    x.rownames = vertcat(x.rownames, repmat({''}, n1 - n, 1));
                end
                if (d1 > d) && ~ isempty (x.colnames)
                    x.colnames = horzcat(x.colnames, repmat({''}, 1, d1 - d));
                end
                
            else  % assignment rhs is empty: deletion
                
                if L == 1,  % linear indexing
                    if d == 1,
                        I = idx(1).subs{1};
                        J = 1;
                    elseif n == 1,
                        I = 1;
                        J = idx(1).subs{1};
                    else
                        stk_error('Illegal indexing.', 'IllegalIndexing');
                    end
                else
                    I = idx(1).subs{1};
                    J = idx(1).subs{2};
                end
                
                remove_columns = (strcmp(I, ':') ...
                    || ((n == 1) && isequal(I, 1)));
                remove_rows = (strcmp(J, ':') ...
                    || ((d == 1) && isequal(J, 1)));
                
                if ~ (remove_columns || remove_rows)
                    
                    stk_error('Illegal indexing.', 'IllegalIndexing');
                    
                elseif remove_columns
                    
                    x.data(:, J) = [];
                    if ~ isempty(x.colnames)
                        x.colnames(J) = [];
                    end
                    
                else % remove_rows
                    
                    x.data(I, :) = [];
                    
                    if ~ isempty (x.rownames)
                        x.rownames(I) = [];
                    end
                    
                end
            end
        end
        
    case '{}'
        
        errmsg = 'Indexing with curly braces is not allowed.';
        stk_error(errmsg, 'IllegalIndexing');
        
    case '.'
        
        if strcmp (idx(1).subs, 'data') && length (idx) > 1,
            
            if strcmp (idx(2).type, '()')
                x = subsasgn (x, idx(2:end), val);
            else
                stk_error('Illegal indexing.', 'IllegalIndexing');
            end
            
        else % other than 'data'
            
            if length (idx) > 1
                val = subsasgn (get (x, idx(1).subs), idx(2:end), val);
            end
            
            x = set (x, idx(1).subs, val);
            
        end
        
end

end % function subsasgn

%!shared x s t data
%! x = stk_dataframe(rand(3, 2));
%! s = {'a'; 'b'; 'c'};
%! t = {'xx' 'yy'};

%!test
%! x.rownames = s;
%! assert (isequal(get(x, 'rownames'), s))

%!test
%! x.colnames = t;
%! assert (isequal(get(x, 'rownames'), s))
%! assert (isequal(get(x, 'colnames'), t))

%!test
%! x.rownames{2} = 'dudule';
%! assert (isequal(get(x, 'rownames'), {'a'; 'dudule'; 'c'}))
%! assert (isequal(get(x, 'colnames'), t))

%!test
%! x.colnames{1} = 'martha';
%! assert (isequal(get(x, 'rownames'), {'a'; 'dudule'; 'c'}))
%! assert (isequal(get(x, 'colnames'), {'martha' 'yy'}))

% %!error x.colnames{1} = 'yy'
% %!error x.colnames = {'xx' 'xx'}

%!test
%! data = stk_dataframe(zeros(3, 2), {'x1' 'x2'});
%! u = rand(3, 1); data.x2 = u;
%! assert (isequal(double(data), [zeros(3, 1) u]))

%!test
%! data = stk_dataframe(zeros(3, 2), {'x1' 'x2'});
%! data.x2(3) = 27;
%! assert (isequal(double(data), [0 0; 0 0; 0 27]))

%!error data.toto = rand(3, 1);

%!shared x
%! x = stk_dataframe(reshape(1:12, 4, 3), {'u' 'v' 'w'});

%!test
%! x(:, 2) = [];
%! assert (isequal (size (x), [4 2]))
%! assert (isequal (double (x), [1 9; 2 10; 3 11; 4 12]))
%! assert (isequal (get (x, 'colnames'), {'u' 'w'}))
%! assert (isempty (get (x, 'rownames')))

%!test
%! x(2, :) = [];
%! assert (isequal (size (x), [3 2]))
%! assert (isequal (double (x), [1 9; 3 11; 4 12]))
%! assert (isempty (get (x, 'rownames')))

%!test
%! x.rownames = {'a'; 'b'; 'c'};
%! x(2, :) = [];
%! assert (isequal (size (x), [2 2]))
%! assert (isequal (double (x), [1 9; 4 12]))
%! assert (isequal (x.rownames, {'a'; 'c'}))

%!test  % change one value with matrix-style indexing
%! x(1, 2) = 11;
%! assert (isequal (size (x), [2 2]))
%! assert (isequal (double (x), [1 11; 4 12]))

%!test  % change one value with linear indexing
%! x(3) = 13;
%! assert (isequal (size (x), [2 2]))
%! assert (isequal (double (x), [1 13; 4 12]))

%!assert (isequal (double (x(:, :)), [1 13; 4 12]));

%!test  % assignment to a variable that doesn't exist
%! A = stk_dataframe (7.1);
%! clear B;  B(2) = A;
%! assert (strcmp (class (B), 'stk_dataframe'))
%! assert (isequal (B.data, [0 7.1]));

%!test  % repmat
%! x = stk_dataframe (1);
%! y = repmat (x, 2, 3);
%! assert (isa (y, 'stk_dataframe'));
%! assert (isequal (y.data, ones (2, 3)));

%!test
%! x(:, :) = [];
%! assert (isempty (x));

%!error x{1} = 2;
%!error x(1, 2) = [];
%!error x(1, 2).a = 3;

%--- tests with a univariate dataframe ----------------------------------------

%!shared x
%! x = stk_dataframe((1:5)');

% linear indexing is allowed for univariate dataframes
%!test x(2) = 0;   assert (isequal (double (x), [1; 0; 3; 4; 5]));
%!test x(3) = [];  assert (isequal (double (x), [1; 0; 4; 5]));

% matrix-style indexing also
%!test x(3, 1) = 0;  assert (isequal(double(x), [1; 0; 0; 5]));

% three indices is not allowed (even if the third is one...)
%!error x(3, 1, 1) = 297;

%!test % create a new row and a new column through subsasgn()
%! x = stk_dataframe(rand(5, 2)); x(6, 3) = 7; disp(x)
%! assert(isequal(size(x), [6, 3]));

%--- tests adding row/columns through row/columns names ------------------------

%!test
%! x = stk_dataframe ([]);
%! x.colnames{2} = 'v';
%! x.rownames{2} = 'b';
%! assert (isequal (x.rownames, {''; 'b'}));
%! assert (isequal (x.colnames, {'' 'v'}));
%! assert (isequalwithequalnans (x.data, nan (2)));