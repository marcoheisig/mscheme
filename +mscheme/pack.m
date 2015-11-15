%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = pack( x )
  if ischar( x ) && isvector( x )
    value = mscheme.String( x );
    return;
  end

  if ismatrix( x ) && ~ isscalar( x ) && ~ iscell( x )
    value = mscheme.Array( x );
    return;
  end

  if iscell( x ) && size( x, 1 ) == 1
    value = mscheme.Vector( x );
    return;
  end

  value = x;
end
