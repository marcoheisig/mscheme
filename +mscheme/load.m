%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = load( filename )
  [ fileID, errmsg ] = fopen( filename.data );
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
