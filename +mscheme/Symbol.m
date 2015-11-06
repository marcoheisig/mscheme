%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) Symbol < handle
  properties
    name
  end

  methods
    function value = Symbol( name )
      persistent table;
      if isempty( table )
        table = containers.Map();
      end
      if isKey( table, name )
        value = table( name );
      else
        value.name = name;
        table( name ) = value;
      end
    end
  end
end
