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
  var TokArrow = '->';
  var TokEquals = '=';
  var TokWhitespace = '<whitespace>';
  var TokIdentifier = '<identifier>';
  var TokBlockIdentifier = '<block-identifier>';
  var TokText = '<text>';
  var TokString = '<string>';
  var TokNewline = '<newline>';
  var TokEof = '<eof>';
  var TokComment = '<comment>';
}
