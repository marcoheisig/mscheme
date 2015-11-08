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
  switch class( op )
    case 'mscheme.Macro' %% TODO expands on each invocation
      expander = op.macroFunction;
      mscheme.eval( mscheme.apply( expander, rest ), env );
    case 'mscheme.SpecialForm'
      switch op.name
        case 'quote'
          if ~ isa( rest.cdr, 'mscheme.Null' )
            error('Quote expects exactly one argument.' );
          end
          value = rest.car;
        case 'if'
          then = rest.cdr.car;
          if isa( rest.cdr.cdr, 'mscheme.Cons' )
            els = rest.cdr.cdr.car;
          else
            els = false;
          end
          condition = mscheme.eval( rest.car, env );
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
        case 'macro'
          value = mscheme.Macro( mscheme.eval( rest.car, env ) );
        case 'lambda'
          [ params, improper ] = mscheme.list_to_cell( rest.car );
          arity = length( params ) * ( 1 - 2 * improper ); % switch sign if improper
          body = mscheme.Cons( mscheme.Symbol( 'begin' ), rest.cdr );
          params = cellfun( @( p ) p.name, params, 'UniformOutput', false );
          value = mscheme.Procedure( params, arity, body, mscheme.Environment( env ) );
      end
    otherwise
      args = cellfun( @( arg ) mscheme.eval( arg, env ), ...
                      mscheme.list_to_cell( rest ), ...
                      'UniformOutput', false );

      value = mscheme.apply( op, args{:}, mscheme.Null() );
  end
end
