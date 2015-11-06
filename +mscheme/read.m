%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = read( varargin )
  if 0 == nargin
    port = mscheme.Port( 'input' );
  else
    port = varargin{ 1 };
  end
  token = port.nextToken( );
  if isa( token, 'mscheme.EOF' )
    value = token;
    return;
  end
  number = '^[-+]?[0-9]*\.?[0-9]+';
  if 0 ~= length( regexp( token, number, 'tokens' ) )
    value = str2num( token );
  elseif strcmp( token (1), '"')
    value = mscheme.String( token( 2 : end - 1 ) );
  elseif length(token) > 2 && strcmp( '#\', token( 1 : 2 ) )
    char = token( 3 : end );
    switch char
      case 'newline'
        value = mscheme.Char( 10 );
      case 'space'
        value = mscheme.Char( 20 );
      otherwise
        value = mscheme.Char( char );
    end
  else
    switch token
      case '#f'
        value = logical(0);
      case '#t'
        value = logical(1);
      case ''''
        value = mscheme.Cons( mscheme.Symbol( 'quote' ), mscheme.read( port ) );
      case '`'
        value = mscheme.Cons( mscheme.Symbol( 'quasiquote' ), mscheme.read( port ) );
      case ','
        value = mscheme.Cons( mscheme.Symbol( 'unquote' ), mscheme.read( port ) );
      case ',@'
        value = mscheme.Cons( mscheme.Symbol( 'unquote-splicing' ), mscheme.read( port ) );
      case '('
        value = readList( port );
      case ')'
        error( '%s can not be used as an ordinary identifier', token );
      case '['
        value = readArray( port );
      case ']'
        error( '%s can not be used as an ordinary identifier', token );
      case '#('
        value = readVector( port );
      case '{'
        error( '%s can not be used as an ordinary identifier', token );
      case '}'
        error( '%s can not be used as an ordinary identifier', token );
      otherwise % a standard symbol
        value = mscheme.Symbol( token );
    end
  end
end

function value = readList( port )
  tail = mscheme.Null();
  head = mscheme.Null();
  while not( strcmp( port.peekToken( ), ')' ) )
    item = mscheme.read( port );
    if strcmp( port.peekToken( ), '.' )
      port.nextToken( );
      tail = read( port );
      if not( strcmp( port.peekToken( ), ')' ) )
        error( 'A pair must be terminated with ), found %s.', closingParen );
      end
    end
    head = mscheme.Cons( item, head );
  end
  port.nextToken();
  %% now reverse the list
  value = tail;
  while not( isa( head, 'mscheme.Null' ) )
    value = mscheme.Cons( head.car(), value );
    head = head.cdr();
  end
end

function value = readVector( port )
  data = {};
  index = 1;
  while true
    if strcmp( port.peekToken( ), ')')
      port.nextToken( );
      value = mscheme.Vector( data );
      return;
    end
    data{ index } = read( port );
    ++ index;
  end
end

function value = readArray( port )
  data = [];
  dims = 1;
  while strcmp( port.peekToken( ), '[' )
    port.nextToken( );
    ++ dims;
  end
  switch dims
    case 1
      i1 = 1;
      while not( strcmp( port.peekToken( ), ']' ) )
        data( i1 ) = read( port );
        ++i1;
      end
      port.nextToken( );
    case 2
      i1 = 1;
      i2 = 1;
      while not( strcmp( port.peekToken( ), ']' ) )
        while not( strcmp( port.peekToken( ), ']' ) )
          data(i2, i1) = read( port );
          ++i1;
        end
        port.nextToken( );
        if strcmp( port.peekToken( ), '[' )
          i1 = 1;
          port.nextToken( );
          ++i2;
        else
          break;
        end
      end
      port.nextToken( );
    otherwise
      error('Array is too high-dimensional - sorry.');
  end
  value = Array( data );
end
