%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

%% library - a trick to avoid the one function per file rule. Given a symbol
%% name, return the local function with that name.
function value = library( name )
  value = mscheme.NativeProcedure( eval(['@', name] ) );
end

function value = quit( )
  value = false;
  errorStruct.message = 'quit';
  errorStruct.identifier = 'mscheme:quit';
  error( errorStruct );
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

function value = macro_p( x )
  value = isa( x, 'mscheme.Macro' );
end

function value = pair_p( x )
  value = isa( x, 'mscheme.Cons' );
end

function value = atom_p( x )
  value = ~ isa( x, 'mscheme.Cons' );
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
  while ~ null_p( rest )
    if ~ pair_p( rest )
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
    value = value + unpack_num( varargin{ i } );
  end
  value = pack_num( value );
end

function value = mul( varargin )
  value = 1;
  for i = 1:nargin
    value = value * unpack_num( varargin{ i } );
  end
  value = pack_num( value );
end

function value = sub( x, varargin )
  switch nargin
    case 1
      value = - x;
    otherwise
      value = x;
      for i = 1 : length( varargin )
        value = value - unpack_num( varargin{ i } );
      end
  end
  value = pack_num( value );
end

function value = div( x, varargin )
  switch nargin
    case 1
      value = inv( unpack_num( x ) );
    otherwise
      value = unpack_num( x );
      for i = 1 : length( varargin )
        value = value / unpack_num( varargin{ i } );
      end
  end
  value = pack_num( value );
end

function value = increasing( varargin )
  value = true;
  varargin = cellfun( @unpack_num, varargin, 'UniformOutput', false );
  for i = 2 : length( varargin )
    value = value & ( varargin{ i - 1 } < varargin{ i } );
  end
  value = pack_num( value );
end

function value = nonincreasing( varargin )
  value = true;
  varargin = cellfun( @unpack_num, varargin, 'UniformOutput', false );
  for i = 2 : length( varargin )
    value = value & ( varargin{ i - 1 } >= varargin{ i } );
  end
  value = pack_num( value );
end

function value = decreasing( varargin )
  value = true;
  varargin = cellfun( @unpack_num, varargin, 'UniformOutput', false );
  for i = 2 : length( varargin )
    value = value & ( varargin{ i - 1 } > varargin{ i } );
  end
  value = pack_num( value );
end

function value = nondecreasing( varargin )
  value = true;
  varargin = cellfun( @unpack_num, varargin, 'UniformOutput', false );
  for i = 2 : length( varargin )
    value = value & ( varargin{ i - 1 } <= varargin{ i } );
  end
  value = pack_num( value );
end

function value = numeric_equality( varargin )
  value = true;
  varargin = cellfun( @unpack_num, varargin, 'UniformOutput', false );
  for i = 2 : length( varargin )
    value = value & ( varargin{ i - 1 } == varargin{ i } );
  end
  value = pack_num( value );
end

function value = minimum( varargin )
  value = unpack_num( varargin{ 1 } );
  for i = 2 : length( varargin )
    value = min( value, unpack_num( varargin{ i } ) );
  end
  value = pack_num( value );
end

function value = maximum( varargin )
  value = unpack_num( varargin{ 1 } );
  for i = 2 : length( varargin )
    value = max( value, unpack_num( varargin{ i } ) );
  end
  value = pack_num( value );
end

function value = absolute( z )
  value = pack_num( abs( unpack_num( z ) ) );
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

function value = truncate( x )
  %% TODO
end

function value = round( x )
  %% TODO
end

function value = rationalize( x, y )
  %% TODO
end

function value = exponent( z )
  value = pack_num( exp( unpack_num( z ) ) );
end

function value = logarithm( z )
  value = pack_num( log( unpack_num( z ) ) );
end

function value = sine( z )
  value = pack_num( sin( unpack_num( z ) ) );
end

function value = cosine( z )
  value = pack_num( cos( unpack_num( z ) ) );
end

function value = tangent( z )
  value = pack_num( tan( unpack_num( z ) ) );
end

function value = arcsine( z )
  value = pack_num( asin( unpack_num( z ) ) );
end

function value = arccosine( z )
  value = pack_num( acos( unpack_num( z ) ) );
end

function value = arctangent( z )
  value = pack_num( atan( unpack_num( z ) ) );
end

function value = squareroot( z )
  value = pack_num( sqrt( unpack_num( z ) ) );
end

function value = power( z1, z2 )
  value = pack_num( unpack_num( z1 ) ^ unpack_num( z2 ) );
end

function value = make_rectangular( x1, x2 )
  %% TODO
end

function value = make_polar( x3, x4 )
  %% TODO
end

function value = real_part( z )
  %% TODO
end

function value = imag_part( z )
  %% TODO
end

function value = magnitude( z )
  value = pack_num( abs( unpack_num( z ) ) );
end

function value = angle( z )
  %% TODO
end

function value = exact_to_inexact( z )
  %% TODO
end

function value = inexact_to_exact( z )
  %% TODO
end

function value = number_to_string( z, varargin )
  %% TODO
end

function value = string_to_number( string, varargin )
  %% TODO
end

%% helper function - called once on each numeric argument to produce an
%% argument that can be passed to the builtin math functions.
function value = unpack_num( value )
  if isscalar( value ) && ( isnumeric( value ) || islogical( value ) )
    return;
  end
  if isa( value, 'mscheme.Array' )
    value = value.data;
    return;
  end
  error('Not a numeric Scheme value.');
end

function value = pack_num( value )
  if isscalar( value ) && ( isnumeric( value ) || islogical( value ) )
    return;
  end
  if ismatrix( value ) && ~ isscalar( value )
    value = mscheme.Array( value );
    return;
  end
  error('Not a numeric value.');
end

%%% Booleans

function value = not_p( obj )
  if islogical( obj ) && isscalar( obj ) && ~ obj
    value = true;
  else
    value = false;
    end
end

%%% Pairs and Lists

function value = cons( obj1, obj2 )
  value = mscheme.Cons( obj1, obj2 );
end

%% TODO The Scheme Standard requires CAR / CDR combinations up to depth 4.

%% depth 1
function value = car( pair )
  value = pair.car;
end

function value = cdr( pair )
  value = pair.cdr;
end

%% depth 2

function value = caar( pair )
  value = pair.car.car;
end

function value = cadr( pair )
  value = pair.cdr.car;
end

function value = cdar( pair )
  value = pair.car.cdr;
end

function value = cddr( pair )
  value = pair.cdr.cdr;
end

%% depth 3

function value = caaar( pair )
  value = pair.car.car.car;
end

function value = cadar( pair )
  value = pair.car.cdr.car;
end

function value = cdaar( pair )
  value = pair.car.car.cdr;
end

function value = cddar( pair )
  value = pair.car.cdr.cdr;
end

function value = caadr( pair )
  value = pair.cdr.car.car;
end

function value = caddr( pair )
  value = pair.cdr.cdr.car;
end

function value = cdadr( pair )
  value = pair.cdr.car.cdr;
end

function value = cdddr( pair )
  value = pair.cdr.cdr.cdr;
end

function value = set_car_f( pair, obj )
  pair.car = obj;
  value = obj;
end

function value = set_cdr_f( pair, obj )
  pair.cdr = obj;
  value = obj;
end

function value = list( varargin )
  value = mscheme.Null();
  for i = length( varargin ) : -1 : 1
    value = mscheme.Cons( varargin{ i }, value );
  end
end

function value = list_length( x )
  value = 0;
  rest = x;
  while ~ isa( rest, 'mscheme.Null' )
    if ~ isa( x, 'mscheme.Cons' )
      error( 'Applied LENGTH to non-list.' );
    end
    rest = rest.cdr;
    value = value + 1;
  end
end

function value = reverse( list )
  value = mscheme.Null();
  rest = list;
  while ~ isa( rest, 'mscheme.Null' )
    value = mscheme.Cons( rest.car, value );
    rest = rest.cdr;
  end
end

function value = nreverse( list )
  predecessor = mscheme.Null();
  head = mscheme.Null();
  rest = list;
  while ~ isa( rest, 'mscheme.Null' )
    head = rest;
    rest = head.cdr;
    head.cdr = predecessor;
    predecessor = head;
  end
  value = head;
end

function value = map( f, varargin )
  lengths = cellfun( @list_length, varargin );
  N = lengths( 1 );
  if ~ all( lengths == N )
    error( 'All input lists to map must have the same length.' );
  end
  value = mscheme.Null();
  rest = varargin;
  for i = 1 : N
    args = cellfun( @(x) x.car, rest, 'UniformOutput', false );
    rest = cellfun( @(x) x.cdr, rest, 'UniformOutput', false );
    value = mscheme.Cons( mscheme.apply( f, args{ : }, mscheme.Null() ), value );
  end
  value = nreverse( value );
end

function value = for_each( f, varargin )
  value = 1;
end

%%% IO

function value = write( obj ) %% TODO port
  mscheme.print( obj, true );
  fprintf( '\n' );
  value = false;
end

function value = display( obj ) %% TODO port
  mscheme.print( obj, false );
  fprintf( '\n' );
  value = false;
end

%%% misc

function value = macro( expander )
  value = mscheme.Macro( expander );
end

function value = macroexpand_1( form )
  if ~ isa( form, 'mscheme.Cons' )
    value = form;
    return;
  end

  %% TODO: support macrolet
  op = mscheme.eval( form.car, mscheme.Environment() );
  rest = form.cdr;
  if isa( op, 'mscheme.Macro' )
    value = mscheme.apply( op.macroFunction, rest );
  else
    value = form;
  end
end
