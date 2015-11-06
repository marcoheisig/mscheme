%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef Macro < mscheme.Procedure
  methods
    function value = Macro( params, arity, body, env )
      value@mscheme.Procedure( params, arity, body, env );
    end
  end
end
