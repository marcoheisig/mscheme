%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = unpack( x )
  if ~ isa( x, 'handle' )
    value = x;
  else
    switch class( x )
      case 'mscheme.Array'
        value = x.data;
      case 'mscheme.Char'
        value = x.data;
      case 'mscheme.Vector'
        value = x.data;
      case 'mscheme.String'
        value = x.data;
      case 'mscheme.Symbol'
        value = x.name;
      otherwise
        value = false;
    end
  end
end
