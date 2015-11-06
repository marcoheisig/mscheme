%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) Null < handle
  methods
    function value = Null( )
      persistent nil
      if isempty( nil )
        nil = value;
      end
      value = nil;
    end
  end
end
