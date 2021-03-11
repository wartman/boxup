package boxup;

enum abstract TokenType(String) to String {
  var TokOpenBracket = '[';
  var TokCloseBracket = ']';
  var TokOpenAngleBracket = '<';
  var TokCloseAngleBracket = '>';
  var TokItalic = '/';
  var TokBold = '*';
  var TokUnderline = '_';
  var TokRaw = '`';
  var TokEquals = '=';
  var TokSymbolExcitement = '!';
  var TokSymbolAt = '@';
  var TokSymbolHash = '#';
  var TokSymbolPercent = '%';
  var TokSymbolDollar = '$';
  var TokSymbolAmp = '&';
  var TokSymbolCarat = '^';
  var TokSymbolDash = '-';
  var TokWhitespace = '<whitespace>';
  var TokIdentifier = '<identifier>';
  var TokBlockIdentifier = '<block-identifier>';
  var TokText = '<text>';
  var TokNewline = '<newline>';
  var TokEof = '<eof>';
  var TokComment = '<comment>';
  var TokSingleQuote = "'";
  var TokDoubleQuote = '"';
}
