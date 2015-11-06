%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef Procedure < handle
  properties
    params %% a cell array of symbols
    arity %% number of arguments, negative means rest list
    body
    env
  end

  methods
    function value = Procedure( params, arity, body, env )
      value.params = params;
      value.arity = arity;
      value.body = body;
      value.env = env;
    end

    function value = call( this, env, varargin )
      if nargin < this.arity
        error( 'Not enough arguments.' );
      end
      if not( this.rest_list_p ) && nargin > this.arity
        error( 'Too many arguments.' );
      end
      args = varargin{ 1 : this.arity }
    end
  end
end
