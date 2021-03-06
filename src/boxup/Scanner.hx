package boxup;

import boxup.stream.Duplex;

class Scanner extends Duplex<Source, Array<Token>> {
  var source:Source = null;
  var position:Int = 0;
  var start:Int = 0;

  public function write(source:Source) {
    this.source = source;
    position = 0;
    start = 0;
    try {
      var out = [ while (!isAtEnd()) scanToken() ];
      out.push({
        type: TokEof,
        value: '',
        pos: {
          min: position,
          max: position,
          file: source.filename
        }
      });
      output.push(out);
    } catch (e:Error) {
      output.fail(e);
    } catch (e) {
      output.fail(error(e.details(), 0, 0));
    }
  }

  function scanToken():Token {
    start = position;
    var r = advance();
    return switch r {
      case ' ': createToken(TokWhitespace);
      case '\r' if (match('\n')): createToken(TokNewline, '\r\n');
      case '\n': createToken(TokNewline);
      case '\\': 
        // Todo: should probably limit escape sequences
        createToken(TokText, advance());
      case '[' if (match('/')): createToken(TokCommentStart, '[/');
      case '/' if (match(']')): createToken(TokCommentEnd, '/]');
      case '[': createToken(TokOpenBracket);
      case ']': createToken(TokCloseBracket);
      case '<': createToken(TokOpenAngleBracket);
      case '>': createToken(TokCloseAngleBracket);
      case '=': createToken(TokEquals);
      case '/': createToken(TokSlash);
      case '_': createToken(TokUnderline);
      case '*': createToken(TokStar);
      case '`': createToken(TokRaw);
      case '"': createToken(TokDoubleQuote);
      case "'": createToken(TokSingleQuote);
      case '!': createToken(TokBang);
      case '@': createToken(TokAt);
      case '#': createToken(TokHash);
      case '%': createToken(TokPercent);
      case '$': createToken(TokDollar);
      case '&': createToken(TokAmp);
      case '^': createToken(TokCarat);
      case '-': createToken(TokDash);
      case '+': createToken(TokPlus);
      case '?': createToken(TokQuestion);
      case ':': createToken(TokColon);
      case ';': createToken(TokSemiColon);
      case '.': createToken(TokDot);
      case ',': createToken(TokComma);
      case '|': createToken(TokPipe);
      case r:
        {
          type: TokText,
          value: r + readWhile(() -> isAlphaNumeric(peek())),
          pos: {
            min: start,
            max: position,
            file: source.filename
          }
        };
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
           (c >= 'A' && c <= 'Z');
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
