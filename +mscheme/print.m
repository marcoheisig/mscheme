%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function print( x, printReadably )
  nil = mscheme.Null( );
  if isa( x, 'mscheme.Symbol' )
    fprintf( '%s', x.name );
  elseif isa( x, 'mscheme.Cons' )
    car = x.car;
    cdr = x.cdr;
    fprintf( '(' );
    while true
      mscheme.print( car );
      if cdr == nil
        fprintf( ')' );
        return;
      elseif not( isa( cdr, 'mscheme.Cons' ) )
        fprintf( ' . ' );
        mscheme.print( cdr );
        fprintf( ')' );
        return;
      end
      fprintf( ' ' );
      car = cdr.car;
      cdr = cdr.cdr;
    end
  elseif isa( x, 'mscheme.Vector' )
    fprintf('#(');
    data = x.data;
    for i = 1 : length(data)
      mscheme.print( data{1, i} );
      if i ~= length( data )
        fprintf(' ');
      end
    end
    fprintf(')');
  elseif isa( x, 'mscheme.String' )
    fprintf( '"%s"', x.data );
  elseif isa( x, 'mscheme.Char' )
    fprintf( '#\\%s', x.data );
  elseif isa( x, 'mscheme.EOF' )
    fprintf( '#<EOF>' );
  elseif isa( x, 'mscheme.Array' )
    data = x.data;
    if numel( data ) > 10000
      fprintf( '#<big array>');
    else
      switch ndims( data )
        case 1
          %% it seems there are no 1D arrays in Matlab/Octave
        case 2
          fprintf( '[' );
          for i1 = 1:size( data, 1 )
            fprintf( '[' );
            for i2 = 1:size( data, 2 )
              mscheme.print( data(i1, i2) );
              fprintf(' ');
            end
            fprintf( ']' );
            if i1 ~= size( data, 1)
              fprintf( '\n ');
            end
          end
          fprintf( ']' );
        otherwise % TODO print more dimensions
          fprintf( '#<multidimensional array>' );
      end
    end
  elseif islogical( x )
    if x
      fprintf( '#t' );
    else
      fprintf( '#f' );
    end
  elseif x == nil
    fprintf( '()' );
  elseif isnumeric( x ) && isscalar( x )
    fprintf( '%g', x ); %% TODO
  elseif isa( x, 'mscheme.Procedure' ) || ...
         isa ( x, 'mscheme.NativeProcedure' ) || ...
         isa( x, 'function_handle' )
    fprintf( '#<procedure>' );
  else
    fprintf( sprintf( '#<unknown-class %s>', class( x ) ) );
  end
end
