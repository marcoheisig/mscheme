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
        for i = 2 : nargin
          value.table( varargin{ i } ) = [];
        end
      else
        if ~ isa( toplevel, 'mscheme.Environment' )
          toplevel = mscheme.Environment( false );
          toplevel.set( 'read', mscheme.NativeProcedure( mscheme.read ) );
          toplevel.set( 'eval', mscheme.NativeProcedure( mscheme.eval ) );
          toplevel.set( 'boolean?', mscheme.library( 'boolean_p' ) );
          toplevel.set( 'symbol?', mscheme.library( 'symbol_p' ) );
          toplevel.set( 'char?', mscheme.library( 'char_p' ) );
          toplevel.set( 'port?', mscheme.library( 'port_p' ) );
          toplevel.set( 'vector?', mscheme.library( 'vector_p' ) );
          toplevel.set( 'array?', mscheme.library( 'array_p' ) );
          toplevel.set( 'procedure?', mscheme.library( 'procedure_p' ) );
          toplevel.set( 'pair?', mscheme.library( 'pair_p' ) );
          toplevel.set( 'number?', mscheme.library( 'number_p' ) );
          toplevel.set( 'string?', mscheme.library( 'string_p' ) );
          toplevel.set( 'null?', mscheme.library( 'null_p' ) );
          toplevel.set( 'list?', mscheme.library( 'list_p' ) );
          toplevel.set( 'eq?', mscheme.library( 'eq_p' ) );
          toplevel.set( 'eqv?', mscheme.library( 'eqv_p' ) );
          toplevel.set( 'equal?', mscheme.library( 'equal_p' ) );
          toplevel.set( '+', mscheme.library( 'add' ) );
          toplevel.set( '*', mscheme.library( 'mul' ) );
          toplevel.set( '-', mscheme.library( 'sub' ) );
          toplevel.set( '/', mscheme.library( 'div' ) );
          toplevel.set( '<', mscheme.library( 'increasing' ) );
          toplevel.set( '>=', mscheme.library( 'nonincreasing' ) );
          toplevel.set( '>', mscheme.library( 'decreasing' ) );
          toplevel.set( '<=', mscheme.library( 'nondecreasing' ) );
          toplevel.set( '=', mscheme.library( 'numeric_equality' ) );
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
  end
end
