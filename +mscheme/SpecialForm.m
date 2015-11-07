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
