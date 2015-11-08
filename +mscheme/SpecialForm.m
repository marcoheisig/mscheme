%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) SpecialForm < handle
  properties
    name
  end
  methods
    function value = SpecialForm( name )
      value.name = name;
    end
  end
end
