%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) Vector < handle
  properties
    data
  end

  methods
    function value = Vector( data )
      value.data = data;
    end
  end
end
