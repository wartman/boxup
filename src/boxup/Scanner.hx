package boxup;

class Scanner {
  final source:Source;
  var position:Int = 0;
  var start:Int = 0;

  public function new(source:Source) {
    this.source = source;  
  }

  public function scan():Outcome<Array<Token>> {
    position = 0;
    start = 0;

    try {
      var tokens = [ while (!isAtEnd()) scanToken() ];
      tokens.push({
        type: TokEof,
        value: '',
        pos: {
          min: position,
          max: position,
          file: source.filename
        }
      });

      return Ok(tokens);
    } catch (e:Error) {
      return Fail(e);
    }
  }

  function scanToken():Token {
    start = position;
    var r = advance();
    return switch r {
      case ' ': createToken(TokWhitespace);
      case '\r' if (match('\n')): createToken(TokNewline, '\r\n');
      case '\n': createToken(TokNewline);
      case '\\': createToken(TokText, '\\' + advance());
      case '[' if (match('/')):
        var value = readWhile(() -> !check(']'));
        consume(']');
        createToken(TokComment, value);
      case '[': createToken(TokOpenBracket);
      case ']': createToken(TokCloseBracket);
      case '<': createToken(TokOpenAngleBracket);
      case '>': createToken(TokCloseAngleBracket);
      case '-' if (match('>')): createToken(TokArrow, '->');
      case '=': createToken(TokEquals);
      case '/': createToken(TokItalic);
      case '_': createToken(TokUnderline);
      case '*': createToken(TokBold);
      case '`': createToken(TokRaw);
      case '"': string('"');
      case "'": string("'");
      case r:
        {
          type: TokText,
          value: r + readWhile(() -> isAlphaNumeric(peek())),
          pos: {
            min: start,
            max: position,
            file: source.filename
          }
        }
    }
  }

  function createToken(type:TokenType, ?value:String):Token {
    return {
      type: type,
      value: value == null ? previous() : value,
      pos: {
        file: source.filename,
        min: start,
        max: position
      }
    };
  }

  function string(delimiter:String):Token {
    var out = '';

    while (!isAtEnd() && !match(delimiter)) {
      out += advance();
      if (previous() == '\\' && !isAtEnd()) {
        out += '\\${advance()}';
      }
    }

    if (isAtEnd()) 
      throw error('Unterminated string', start, position);
    
    return {
      type: TokString,
      value: out,
      pos: {
        file: source.filename,
        min: start,
        max: position
      }
    };
  }

  function match(value:String) {
    if (check(value)) {
      position = position + value.length;
      return true;
    }
    return false;
  }

  function check(value:String) {
    var found = source.content.substr(position, value.length);
    return found == value;
  }

  function peek() {
    return source.content.charAt(position);
  }

  function advance() {
    if (!isAtEnd()) position++;
    return previous();
  }

  function previous() {
    return source.content.charAt(position - 1);
  }

  function isDigit(c:String):Bool {
    return c >= '0' && c <= '9';
  }

  function isAlpha(c:String):Bool {
    return (c >= 'a' && c <= 'z') ||
           (c >= 'A' && c <= 'Z') ||
            c == '_';
  }

  function isAlphaNumeric(c:String) {
    return isAlpha(c) || isDigit(c);
  }

  function readWhile(compare:()->Bool):String {
    var out = [ while (!isAtEnd() && compare()) advance() ];
    return out.join('');
  }

  function isAtEnd() {
    return position >= source.content.length;
  }

  function consume(value:String) {
    if (!match(value)) throw error('Expected ${value}', position, position+1);
  }

  function error(msg:String, min:Int, max:Int) {
    return new Error(msg, {
      min: min,
      max: max,
      file: source.filename
    });
  }
}