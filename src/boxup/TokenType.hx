package boxup;

enum abstract TokenType(String) to String {
  var TokOpenBracket = '[';
  var TokCloseBracket = ']';
  var TokOpenAngleBracket = '<';
  var TokCloseAngleBracket = '>';
  var TokComma = ',';
  var TokStar = '*';
  var TokUnderline = '_';
  var TokRaw = '`';
  var TokEquals = '=';
  var TokBang = '!';
  var TokQuestion = '?';
  var TokSlash = '/';
  var TokAt = '@';
  var TokHash = '#';
  var TokPercent = '%';
  var TokDollar = '$';
  var TokAmp = '&';
  var TokCarat = '^';
  var TokDash = '-';
  var TokPlus = '+';
  var TokColon = ':';
  var TokSemiColon = ';';
  var TokDot = '.';
  var TokPipe = '|';
  var TokWhitespace = '<whitespace>';
  var TokIdentifier = '<identifier>';
  var TokBlockIdentifier = '<block-identifier>';
  var TokText = '<text>';
  var TokNewline = '<newline>';
  var TokEof = '<eof>';
  var TokCommentStart = '[/';
  var TokCommentEnd = '/]';
  var TokSingleQuote = "'";
  var TokDoubleQuote = '"';
}
