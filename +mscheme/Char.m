%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) Char < handle
  properties
    data
  end

  methods
    function value = Char( x )
      c = char( x );
      persistent table;
      if isempty( table )
        table = containers.Map();
      end
      if isKey( table, c )
        value = table( c );
      else
        value.data = c;
        table( c ) = value;
      end
    end
  end
end
