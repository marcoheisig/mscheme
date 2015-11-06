%%% Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

function value = grammar( )
  persistent grammar;
  if ischar( grammar )
    value = grammar;
    return;
  end
  peculiar_identifier = '[+\-]';
  special_subsequent = '[+\-\.@]';
  digit = '[0-9]';
  special_initial = '[!$%&\*/:<=>\?\^_~]';
  boolean = '(?:#t|#f)';
  letter = '[a-zA-Z]';
  character = '#\\(?:space|newline|.)';
  string = '"(?:\\.|[^"])*"';
  comment = ';[^\n]*';
  number = '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?';
  intertoken_space = [ '(?:\s|', comment, ')*'];
  initial = ['(?:', letter, '|', special_initial, ')'];
  subsequent = ['(?:', initial, '|', digit, '|', special_subsequent, ')'];
  identifier = ['(?:', initial, subsequent, '*|', peculiar_identifier, ')'];
  token = ['(?<token>', ...
           ',@|', ...
           string, '|', ...
           number, '|', ...
           identifier, '|', ...
           boolean, '|', ...
           character, '|', ...
           '\(|\)|#\(|''|`|,|.', ...
           ')'];
  grammar = [intertoken_space, token, '?', intertoken_space];
  value = grammar;
end
