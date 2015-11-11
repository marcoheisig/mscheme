%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = load( filename )
  switch class( filename )
    case 'mscheme.String'
      filename = filename.data;
    case 'char'
    otherwise
      error( 'The procedure load expects an argument of type string' );
  end
  [ fileID, errmsg ] = fopen( filename );
  if ~ isempty( errmsg )
    error( errmsg );
  end
  port = mscheme.Port( 'file', fileID );
  env = mscheme.Environment();
  while true
    expr = mscheme.read( port );
    if isa( expr, 'mscheme.EOF' )
      break;
    end
    mscheme.eval( expr, env );
  end
  port.close();
  value = false;
end
