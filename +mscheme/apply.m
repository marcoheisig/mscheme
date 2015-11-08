%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = apply( proc, varargin )
  %% 1. convert all args to a cell array
  rest = mscheme.list_to_cell( varargin{ end } );
  if isempty( rest )
    args = { varargin{ 1 : end - 1 } };
  else
    args = { varargin{ 1 : end - 1}, rest{ : } };
  end
  nargs = length( args );
  switch class( proc )
    case 'mscheme.Procedure'
      arity = abs( proc.arity );
      if proc.arity < 0 %% a vararg procedure
        fixedArgs = arity - 1;
        if nargs < fixedArgs
          error( sprintf( 'Expected at least %d arguments but got only %d.', ...
                          fixedArgs, nargs ) );
        end
        %% build the rest list
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
      %% pass arguments
      for i = 1 : arity
        proc.env.set( proc.params{ i }, args{ i } );
      end
      %% backup current bindings
      backup = cellfun( @( param ) proc.env.lookup( param ), proc.params, 'UniformOutput', false );

      %% evaluate function
      value = mscheme.eval( proc.body, proc.env );

      %% restore environment
      for i = 1 : arity
        proc.env.set( proc.params{ i }, backup{ i } );
      end
    case 'mscheme.NativeProcedure'
      value = proc.handle( args{ : } );
    case 'function_handle'
      args = cellfun( @( arg ) unpack( arg ), args, ...
                      'UniformOutput', false );
      value = pack( proc( args{:} ) );
    otherwise
      error( 'The first argument to apply cannot be of type %s', class( proc ) );
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
