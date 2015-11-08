%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function [ value, improper ] = list_to_cell( x )
  value = {};
  improper = false;
  rest = x;
  while isa( rest, 'mscheme.Cons' )
    value = { value{:}, rest.car };
    rest = rest.cdr;
  end

  if ~ isa( rest, 'mscheme.Null' )
    if nargout == 2
      improper = true;
      value = { value{:}, rest};
    else
      error( 'Encountered an improper list.' );
      return;
    end
  end
end
