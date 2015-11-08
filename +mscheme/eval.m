%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = eval( x, env )
  %{
fprintf( 'EVAL: ' );
  mscheme.print( x );
  fprintf( '\n' );
  %}
  if ~ isa( x, 'mscheme.Cons' )
    if isa( x, 'mscheme.Symbol' )
      value = env.lookup( x.name );
      return;
    end
    %% self evaluating objects
    value = x;
    return;
  end

  %% evaluate the S-expression
  op = mscheme.eval( x.car, env );
  rest  = x.cdr;
  nargs = list_length( rest );
  switch class( op )
    case 'mscheme.Macro' %% TODO expands on each invocation
      expander = op.macroFunction;
      args = list_to_cell( rest );
      arity = length( args );
      backup = cellfun( @( param ) env.lookup( param ), expander.params, 'UniformOutput', false );
      for i = 1 : arity
        expander.env.set( expander.params{ i }, args{ i } );
      end
      expansion = mscheme.eval( expander.body, expander.env );
      for i = 1 : arity
        expander.env.set( expander.params{ i }, backup{ i } );
      end
      value = mscheme.eval( expansion, env );
    case 'mscheme.Procedure'
      args = cellfun( @( arg ) mscheme.eval( arg, env ), ...
                      list_to_cell( rest ), ...
                      'UniformOutput', false );
      nargs = length( args );
      arity = abs( op.arity );
      if op.arity < 0 %% a vararg procedure
        fixedArgs = arity - 1;
        if nargs < fixedArgs
          error( sprintf( 'Expected at least %d arguments but got only %d.', ...
                          fixedArgs, nargs ) );
        end
        restlist = mscheme.Null();
        for i = nargs : -1 : fixedArgs + 1
          restlist = mscheme.Cons( args{ i }, restlist );
        end
        args = { args{ 1 : fixedArgs }, restlist };
      else
        if nargs ~= arity
          error( sprintf( 'Expected %d arguments but got %d.', ...
                          arity, nargs ) );
        end
      end
      %% backup current bindings
      backup = cellfun( @( param ) env.lookup( param ), op.params, 'UniformOutput', false );
      %% pass arguments
      for i = 1 : arity
        op.env.set( op.params{ i }, args{ i } );
      end
      %% evaluate function
      value = mscheme.eval( op.body, op.env );
      %% restore environment
      for i = 1 : arity
        op.env.set( op.params{ i }, backup{ i } );
      end
      %% TODO optimize tail calls
    case 'mscheme.NativeProcedure'
      args = cellfun( @( arg ) mscheme.eval( arg, env ), ...
                      list_to_cell( rest ), ...
                      'UniformOutput', false );
      value = op.handle( args{:} );
    case 'function_handle'
      args = cellfun( @( arg ) unpack( mscheme.eval( arg, env ) ), ...
                      list_to_cell( rest ), ...
                      'UniformOutput', false );
      value = pack( op( args{:} ) );
    case 'mscheme.SpecialForm'
      switch op.name
        case 'quote'
          if nargs ~= 1
            error('Quote expects one argument, but got %d.', nargs);
          else
            value = rest.car;
          end
        case 'if'
          condition = mscheme.eval( rest.car, env );
          switch nargs
            case 2
              then = rest.cdr.car;
              els = false;
            case 3
              then = rest.cdr.car;
              els  = rest.cdr.cdr.car;
            otherwise
              error('Wrong number of clauses in IF statement.');
          end
          if ~ ( islogical( condition ) && isscalar( condition ) && ~ condition )
            value = mscheme.eval( then, env );
          else
            value = mscheme.eval( els, env );
          end
        case 'set!' %% TODO: set! should be a macro
          symbol = rest.car;
          form = rest.cdr.car;
          value = mscheme.eval( form, env );
          env.set( symbol.name, value );
        case 'begin'
          value =  {};
          while ~ isa( rest, 'mscheme.Null' )
            value = mscheme.eval( rest.car, env );
            rest = rest.cdr;
          end
        case 'lambda'
          [ params, improper ] = list_to_cell( rest.car );
          arity = length( params ) * ( 1 - 2 * improper ); % switch sign if improper
          body = mscheme.Cons( mscheme.Symbol( 'begin' ), rest.cdr );
          params = cellfun( @( p ) p.name, params, 'UniformOutput', false );
          value = mscheme.Procedure( params, arity, body, mscheme.Environment( env ) );
      end
    otherwise
      error( sprintf('No way to call an object of type %s', class( op ) ) );
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

function [ value, improper ] = list_to_cell( x )
  value = {};
  improper = false;
  rest = x;
  while isa( rest, 'mscheme.Cons' )
    value = { value{:}, rest.car };
    rest = rest.cdr;
  end

  if ~ isa( rest, 'mscheme.Null' )
    if nargout == 2
      improper = true;
      value = { value{:}, rest};
    else
      error( 'Encountered an improper list.' );
      return;
    end
  end
end

function value = unpack( x )
  if ~ isa( x, 'handle' )
    value = x;
  else
    switch class( x )
      case 'mscheme.Array'
        value = x.data;
      case 'mscheme.Char'
        value = x.data;
      case 'mscheme.Vector'
        value = x.data;
      case 'mscheme.String'
        value = x.data;
      case 'mscheme.Symbol'
        value = x.name;
      otherwise
        value = false;
    end
  end
end

function value = pack( x )
  if ischar( x ) && isvector( x )
    value = mscheme.String( x );
    return;
  end

  if ismatrix( x ) && ~ isscalar( x ) && ~ iscell( x )
    value = mscheme.Array( x );
    return;
  end

  if iscell( x ) && size( x, 1 ) == 1
    value = mscheme.Vector( x );
    return;
  end

  value = x;
end
