%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

%% library - a trick to avoid the one function per file rule. Given a symbol
%% name, return the local function with that name.
function value = library( name )
  value = mscheme.NativeProcedure( eval(['@', name] ) );
end

%%% predicates

function value = boolean_p( x )
  value = islogical( x );
end

function value = symbol_p( x )
  value = isa( x, 'mscheme.Symbol' );
end

function value = char_p( x )
  value = isa( x, 'mscheme.Char' );
end

function value = port_p( x )
  value = isa( x, 'mscheme.Port' );
end

function value = vector_p( x )
  value = isa( x, 'mscheme.Vector' );
end

function value = array_p( x )
  value = isa( x, 'mscheme.Array' );
end

function value = procedure_p( x )
  value = isa( x, 'mscheme.NativeProcedure' ) || ...
          isa( x, 'mscheme.Procedure' )
end

function value = pair_p( x )
  value = isa( x, 'mscheme.Cons' );
end

function value = number_p( x )
  value = isnumeric( x ) && isscalar( x );
end

%% TODO complex_p real_p rational_p integer_p

function value = string_p( x )
  value = iscell( x ) && isvector( x );
end

function value = null_p( x )
  isa( x, 'mscheme.Null' );
end

function value = list_p( x )
  rest = x;
  while not( null_p( rest ) )
    if not( pair_p( rest ) )
      value = false;
      return;
    else
      rest = rest.cdr;
    end
  end
  value = true;
end

%% TODO zero_p odd_p even_p positive_p negative_p

%%% equality predicates

function value = eq_p( a, b )
  try
    value = eq( a, b ); % luckily this works on handles, too
  catch
    value = false;
  end
end

function value = eqv_p( a, b )
  try
    value = eq( a, b );
  catch
    value = false;
  end
end

function value = equal_p( a, p )
  if ~ strcmp( class( a ), class( b ) )
    value = false;
    return;
  end
  switch class( a )
    case 'mscheme.Array'
      value = isequal( a.data, b.data );
    case 'mscheme.String'
      value = isequal( a.data, b.data );
    case 'mscheme.Vector'
      ad = a.data;
      bd = b.data
      for i = 1 : length( ad )
        if ~ eqv_p( ad{ i }, bd{ i } )
          value = false;
          return;
        end
      end
      value = true;
      return;
    case 'mscheme.Cons'
      value = eqv_p( a.car, b.car ) && equal_p( a.cdr, b.cdr );
    otherwise
      value = false;
  end
end

%%% arithmetic functions

function value = add( varargin )
  value = 0;
  for i = 1:nargin
    value = value + varargin{ i };
  end
end

function value = mul( varargin )
  value = 1;
  for i = 1:nargin
    value = value * varargin{ i };
  end
end

function value = sub( x, varargin )
  switch nargin
    case 1
      value = - x;
    otherwise
      value = x;
      for i = 1 : length( varargin )
        value = value - varargin{ i };
      end
  end
end

function value = div( x, varargin )
  switch nargin
    case 1
      value = inverse( x );
    otherwise
      value = x;
      for i = 1:length( varargin )
        value = value / varargin{ i };
      end
  end
end

function value = increasing( varargin )
  value = true;
  for i = 2 : length( varargin )
    if ~ ( varargin{ i - 1 } < varargin{ i } )
      value = false;
      return;
    end
  end
end

function value = nonincreasing( varargin )
  value = true;
  for i = 2 : length( varargin )
    if ( varargin{ i - 1 } < varargin{ i } )
      value = false;
      return;
    end
  end
end

function value = decreasing( varargin )
  value = true;
  for i = 2 : length( varargin )
    if ~ ( varargin{ i - 1 } > varargin{ i } )
      value = false;
      return;
    end
  end
end

function value = nondecreasing( varargin )
  value = true;
  for i = 2 : length( varargin )
    if ( varargin{ i - 1 } > varargin{ i } )
      value = false;
      return;
    end
  end
end

function value = numeric_equality( varargin )
  value = true;
  for i = 2 : length( varargin )
    if ~ ( varargin{ i - 1 } == varargin{ i } )
      value = false;
      return;
    end
  end
end

function value = min( varargin )
  value = false;
  %% TODO
end

function value = max( varargin )
  value = false;
  %% TODO
end

function value = abs( x )
  %% TODO
end

function value = quotient( n1, n2 )
  %% TODO
end

function value = remainder( n1, n2 )
  %% TODO
end

function value = modulo( n1, n2 )
  %% TODO
end

function value = gcd( varargin )
  %% TODO
end

function value = lcm( varargin )
  %% TODO
end

function value = numerator( q )
  %% TODO
end

function value = denominator( q )
  %% TODO
end

function value = floor( x )
  %% TODO
end

function value = ceiling( x )
  %% TODO
end
