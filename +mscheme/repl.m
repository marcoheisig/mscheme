%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function repl( )
  env = mscheme.Environment( );
  while true
    mscheme.print( mscheme.eval( mscheme.read( ), env ) );
    fprintf( '\n' );
    try
      %%mscheme.print( mscheme.eval( mscheme.read( ), env ) );
    catch error
      if strcmp( error.identifier, 'mscheme:quit' )
        return;
      end
      fprintf( 'Error: %s\n', error.message );
    end
  end
end
