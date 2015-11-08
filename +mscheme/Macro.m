%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef Macro < handle
  properties
    macroFunction
  end
  methods
    function value = Macro( macroFunction )
      value.macroFunction = macroFunction;
    end
  end
end
