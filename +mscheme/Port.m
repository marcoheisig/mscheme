%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

classdef (Sealed) Port < handle
  properties
    type
    fileID
    string

    tokens
    tokenIndex
  end
  methods

    function value = Port( type, varargin )
      value.type = type;
      value.tokens = {};
      value.tokenIndex = 1;
      switch type
        case 'file'
          value.fileID = varargin{ 1 };
        case 'string'
          value.string = varargin{ 1 };
        case 'input'
          %% do nothing
      end
    end

    function value = readLine( this )
      switch this.type
        case 'file'
          if feof( this.fileID )
            value = mscheme.EOF();
          else
            value = fgetl( fileID );
          end
        case 'string'
          if 0 == length( this.string )
            value = mscheme.EOF();
          else
            line_endings = regexp( this.string, '.*$', 'end' );
            if length( line_endings ) == 0
              value = mscheme.EOF();
            else
              pos = line_endings( 1 );
              value = this.string( 1 : pos );
              this.string = this.string( pos + 1 : end );
            end
          end
        case 'input'
          value = input( '> ', 's' );
      end
    end

    function value = peekToken( this )
      while this.tokenIndex > length( this.tokens )
        nextLine = this.readLine( );
        if isa( nextLine, 'mscheme.EOF' )
          value = nextLine;
          return;
        end
        if length( nextLine ) == 0
          continue;
        end
        parse = regexp( nextLine, mscheme.grammar( ), 'tokens' );
        if not( isempty( parse{ 1 } ) )
          this.tokens = cellfun( @(x) x(1), parse );
        end
        this.tokenIndex = 1;
      end
      value = this.tokens{ this.tokenIndex };
    end

    function value = nextToken( this )
      value = this.peekToken( );
      this.tokenIndex = this.tokenIndex + 1;
    end
  end
end
