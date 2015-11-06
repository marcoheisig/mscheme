%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) Cons < handle
  properties
    car
    cdr
  end
  methods
    function value = Cons( car, cdr )
      value.car = car;
      value.cdr = cdr;
    end
  end
end
