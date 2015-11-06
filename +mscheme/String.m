%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) String < handle
  properties
    data
  end

  methods
    function value = String( data )
      value.data = data;
    end
  end
end
