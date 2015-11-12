%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function repl( )
  env = mscheme.Environment( );
  env.init();
  while true
    try
      mscheme.print( mscheme.eval( mscheme.read( ), env ) );
      fprintf( '\n' );
    catch error
      if strcmp( error.identifier, 'mscheme:quit' )
        return;
      end
      fprintf( 'Error: %s\n', error.message );
    end
  end
end
