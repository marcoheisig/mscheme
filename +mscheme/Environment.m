%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) Environment < handle
  properties
    table
    parent
  end
  methods
    function value = Environment( varargin )
      persistent toplevel;

      if nargin >= 1
        value.table = containers.Map();
        value.parent = varargin{1};
        %% establish initial bindings
        for i = 2 : nargin
          value.table( varargin{ i } ) = [];
        end
      else
        if ~ isa( toplevel, 'mscheme.Environment' )
          toplevel = mscheme.Environment( false );
          toplevel.init();
        end
        value = toplevel;
      end
    end

    function value = lookup( this, key )
      env = this;
      while isa( env, 'mscheme.Environment' )
        if isKey( env.table, key )
          value = env.table( key );
          return;
        end
        env = env.parent;
      end
      value = eval( ['@', key ], 'false' );
      if islogical( value )
        error('Reference to undefined symbol %s', key);
      end
    end

    function value = set( this, key, value )
      env = this;
      while isa( env, 'mscheme.Environment' )
        if isKey( env.table, key )
          env.table( key ) = value;
          return;
        end
        env = env.parent;
      end
      this.table( key ) = value;
    end

    function init( toplevel )
      t = containers.Map( );
      t( 'if' ) = mscheme.SpecialForm( 'if' );
      t( 'quote' ) = mscheme.SpecialForm( 'quote' );
      t( 'quasiquote' ) = mscheme.SpecialForm( 'quasiquote' );
      t( 'unquote' ) = mscheme.SpecialForm( 'unquote' );
      t( 'unquote-splicing' ) = mscheme.SpecialForm( 'unquote-splicing' );
      t( 'set!' ) = mscheme.SpecialForm( 'set!' );
      t( 'begin' ) = mscheme.SpecialForm( 'begin' );
      t( 'lambda' ) = mscheme.SpecialForm( 'lambda' );
      t( 'values' ) = mscheme.SpecialForm( 'values' );
      t( 'bind!' ) = mscheme.SpecialForm( 'bind!' );
      t( 'apply' ) = mscheme.NativeProcedure( @mscheme.apply );
      t( 'read' ) = mscheme.NativeProcedure( @mscheme.read );
      t( 'eval' ) = mscheme.NativeProcedure( @mscheme.eval );
      t( 'load' ) = mscheme.NativeProcedure( @mscheme.load );
      t( 'quit' ) = mscheme.library( 'quit' );
      t( 'boolean?' ) = mscheme.library( 'boolean_p' );
      t( 'symbol?' ) = mscheme.library( 'symbol_p' );
      t( 'char?' ) = mscheme.library( 'char_p' );
      t( 'port?' ) = mscheme.library( 'port_p' );
      t( 'vector?' ) = mscheme.library( 'vector_p' );
      t( 'array?' ) = mscheme.library( 'array_p' );
      t( 'procedure?' ) = mscheme.library( 'procedure_p' );
      t( 'macro?' ) = mscheme.library( 'macro_p' );
      t( 'pair?' ) = mscheme.library( 'pair_p' );
      t( 'atom?' ) = mscheme.library( 'atom_p' );
      t( 'number?' ) = mscheme.library( 'number_p' );
      t( 'number?' ) = mscheme.library( 'number_p' );
      t( 'string?' ) = mscheme.library( 'string_p' );
      t( 'null?' ) = mscheme.library( 'null_p' );
      t( 'list?' ) = mscheme.library( 'list_p' );
      t( 'eq?' ) = mscheme.library( 'eq_p' );
      t( 'eqv?' ) = mscheme.library( 'eqv_p' );
      t( 'equal?' ) = mscheme.library( 'equal_p' );
      t( '+' ) = mscheme.library( 'add' );
      t( '*' ) = mscheme.library( 'mul' );
      t( '-' ) = mscheme.library( 'sub' );
      t( '/' ) = mscheme.library( 'div' );
      t( '<' ) = mscheme.library( 'increasing' );
      t( '>=' ) = mscheme.library( 'nonincreasing' );
      t( '>' ) = mscheme.library( 'decreasing' );
      t( '<=' ) = mscheme.library( 'nondecreasing' );
      t( '=' ) = mscheme.library( 'numeric_equality' );
      t( 'min' ) = mscheme.library( 'minimum' );
      t( 'max' ) = mscheme.library( 'maximum' );
      t( 'abs' ) = mscheme.library( 'absolute' );
      t( 'exp' ) = mscheme.library( 'exponent' );
      t( 'log' ) = mscheme.library( 'logarithm' );
      t( 'sin' ) = mscheme.library( 'sine' );
      t( 'cos' ) = mscheme.library( 'cosine' );
      t( 'tan' ) = mscheme.library( 'tangent' );
      t( 'asin' ) = mscheme.library( 'arcsine' );
      t( 'acos' ) = mscheme.library( 'arccosine' );
      t( 'acos' ) = mscheme.library( 'arctangent' );
      t( 'sqrt' ) = mscheme.library( 'squareroot' );
      t( 'expt' ) = mscheme.library( 'power' );
      t( 'magnitude' ) = mscheme.library( 'magnitude' );
      t( 'not' ) = mscheme.library( 'not_p' );
      t( 'cons' ) = mscheme.library( 'cons' );

      t( 'car' ) = mscheme.library( 'car' );
      t( 'cdr' ) = mscheme.library( 'cdr' );

      t( 'caar' ) = mscheme.library( 'caar' );
      t( 'cdar' ) = mscheme.library( 'cdar' );
      t( 'cadr' ) = mscheme.library( 'cadr' );
      t( 'cddr' ) = mscheme.library( 'cddr' );

      t( 'caaar' ) = mscheme.library( 'caaar' );
      t( 'cdaar' ) = mscheme.library( 'cdaar' );
      t( 'cadar' ) = mscheme.library( 'cadar' );
      t( 'cddar' ) = mscheme.library( 'cddar' );
      t( 'caadr' ) = mscheme.library( 'caadr' );
      t( 'cdadr' ) = mscheme.library( 'cdadr' );
      t( 'caddr' ) = mscheme.library( 'caddr' );
      t( 'cdddr' ) = mscheme.library( 'cdddr' );

      t( 'set-car!' ) = mscheme.library( 'set_car_f' );
      t( 'set-cdr!' ) = mscheme.library( 'set_cdr_f' );
      t( 'list' ) = mscheme.library( 'list' );
      t( 'length' ) = mscheme.library( 'list_length' );
      t( 'map' ) = mscheme.library( 'map' );

      t( 'write' ) = mscheme.library( 'write' );
      t( 'display' ) = mscheme.library( 'display' );
      t( 'macro' ) = mscheme.library( 'macro' );
      t( 'macroexpand-1' ) = mscheme.library( 'macroexpand_1' );
      toplevel.table = t;
      mscheme.load( '+mscheme/library.scm' );
    end
  end
end
