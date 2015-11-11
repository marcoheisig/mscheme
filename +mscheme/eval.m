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
      value = mscheme.eval( mscheme.apply( expander, rest ), env );
    case 'mscheme.SpecialForm'
      switch op.name
        case 'quote'
          if ~ isa( rest.cdr, 'mscheme.Null' )
            error('Quote expects exactly one argument.' );
          end
          value = rest.car;
        case 'quasiquote'
          value = quasiquote( rest.car, env );
          %fprintf( 'after expansion:\n' );
          %mscheme.print( value, false );
          %fprintf( '\n' );
        case 'unquote'
          error( 'An unquote must be within a quasiquote.' );
        case 'unquote-splicing'
          error( 'An unquote-splicing must be within a quasiquote.' );
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

function [ value, splice ] = quasiquote( expr, env )
  switch class( expr )
    case 'mscheme.Cons'
      if isa( expr.car, 'mscheme.Symbol' )
        if strcmp( expr.car.name, 'unquote' )
          value = mscheme.eval( expr.cdr.car, env );
          splice = false;
          return;
        elseif strcmp( expr.car.name, 'unquote-splicing' )
          value = mscheme.eval( expr.cdr.car, env );
          splice = true;
          return;
        end
      end
      value = quasiquote_list( expr, env );
      splice = false;
    case 'mscheme.Vector'
      %% TODO
      value = false;
      splice = false;
    otherwise
      value = expr;
      splice = false;
  end
end

function value = quasiquote_list( list, env )
  [ tokens, improper ] = mscheme.list_to_cell( list );
  if improper
    value = quasiquote( tokens{ end }, env );
    tokens = { tokens{ 1 : end-1 } };
  else
    value = mscheme.Null();
  end
  for i = length( tokens ) : -1 : 1
    [ element, splice ] = quasiquote( tokens{ i }, env );
    if splice
      subtokens = mscheme.list_to_cell( element ); %% TODO handle improper lists?
      for j = length( subtokens ) : -1 : 1
        value = mscheme.Cons( subtokens{ j }, value );
      end
    else
      value = mscheme.Cons( element, value );
    end
  end
end
