%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function varargout = apply_varargout( N, proc, varargin )
  rest = mscheme.list_to_cell( varargin{ end } );
  if isempty( rest ) % last argument to apply is the rest list
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
      values = mscheme.eval( proc.body, proc.env );
      if ~ iscell( values ) || N ~= length( values )
        error( 'Received the wrong number of values.' );
      end
      varargout = values;

      %% restore environment
      for i = 1 : arity
        proc.env.set( proc.params{ i }, backup{ i } );
      end
    case 'mscheme.NativeProcedure'
      %% all native procedures have only one output argument
      varargout{ 1 } = proc.handle( args{ : } );
    case 'function_handle'
      args = cellfun( @( arg ) mscheme.unpack( arg ), args, ...
                      'UniformOutput', false );
      [ varargout{ 1 : N } ] = proc( args{:} );
      varargout = cellfun( @mscheme.pack, varargout, 'UniformOutput', false );
    otherwise
      error( 'The first argument to apply cannot be of type %s', class( proc ) );
  end
end
