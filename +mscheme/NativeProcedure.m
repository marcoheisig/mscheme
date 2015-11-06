%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) NativeProcedure < handle
  properties
    handle
  end
  methods
    function value = NativeProcedure( handle )
      value.handle = handle;
    end
  end
end
