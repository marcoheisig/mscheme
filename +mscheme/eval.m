%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = eval( x, env )
%{
fprintf( 'EVAL: ' );
  mscheme.print( x );
  fprintf( '\n' );
%}

  if isa( x, 'mscheme.Cons' )
    first = x.car;
    rest  = x.cdr;
    nargs = list_length( rest );

    %% handle special forms
    if isa( first, 'mscheme.Symbol' )
      switch first.name
        case 'quit'
          errorStruct.message = 'quit';
          errorStruct.identifier = 'mscheme:quit';
          error( errorStruct )
        case 'quote'
          if nargs ~= 1
            error('Quote expects one argument, but got %d.', nargs);
          else
            value = rest.car;
            return;
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
          if not( islogical( condition ) ) || condition
            value = mscheme.eval( then, env );
          else
            value = mscheme.eval( els, env );
          end
          return;
        case 'set!'
          symbol = rest.car;
          form = rest.cdr.car;
          value = mscheme.eval( form, env );
          env.set( symbol.name, value );
          return;
        case 'progn'
          value =  {};
          while ~ isa( rest, 'mscheme.Null' )
            value = mscheme.eval( rest.car, env );
            rest = rest.cdr;
          end
          return;
        case 'lambda'
          params = list_to_cell( rest.car );
          arity = length( params );
          body = mscheme.Cons( mscheme.Symbol( 'progn' ), rest.cdr );
          params = cellfun( @( x ) x.name, params, 'UniformOutput', false );
          value = mscheme.Procedure( params, arity, body, mscheme.Environment( env ) );
          return;
      end
    end %% end of special forms
    %% ordinary calls
    f = mscheme.eval( first, env );
    args = cellfun( @( arg ) mscheme.eval( arg, env ), ...
                    list_to_cell( rest ), ...
                    'UniformOutput', false );
    arity = length( args );

    if isa( f, 'function_handle' )
      args = cellfun( @unpack, args, 'UniformOutput', false );
      value = pack( f( args{:} ) );
    elseif isa( f, 'mscheme.NativeProcedure' )
      value = f.handle( args{:} );
    elseif isa( f, 'mscheme.Procedure' )
      %% save
      backup = cellfun( @( param ) env.lookup( param ), f.params, 'UniformOutput', false );
      %% bind
      for i = 1 : arity
        f.env.set( f.params{ i }, args{ i } );
      end
      %% exec
      value = mscheme.eval( f.body, f.env );
      %% restore
      for i = 1 : arity
        f.env.set( f.params{ i }, backup{ i } );
      end
    else
      error('Invalid function call.');
    end
  elseif isa( x, 'mscheme.Symbol' )
    value = env.lookup( x.name );
  else % self evaluating objects
    value = x;
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

function value = list_to_cell( x )
  value = {};
  i = 1;
  rest = x;
  while ~ isa( rest, 'mscheme.Null' )
    if  ~ isa( rest, 'mscheme.Cons' )
      error('Argument is not a proper list.');
    end
    value = { value{:}, rest.car };
    rest = rest.cdr;
    ++ i;
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
