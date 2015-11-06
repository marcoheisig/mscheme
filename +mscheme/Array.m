%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) Array < handle
  properties
    data
  end

  methods
    function value = Array( data )
      value.data = data;
    end
  end
end
