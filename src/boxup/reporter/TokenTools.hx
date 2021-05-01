package boxup.reporter;

using Lambda;
using StringTools;

class TokenTools {
  public static function getTokenByPos(tokens:Array<Token>, pos:Position) {
    return tokens.find(t -> t.pos.min == pos.min); 
  }

  // @todo: Lot of repeating myself here. Simplify this!!

  public static function getLine(tokens:Array<Token>, lineNumber:Int):{ line:Int, newlinePos:Position, pos:Position } {
    if (lineNumber == 1) return getLineAt(tokens, 0);

    var line = 1;
    var index = 0;
    var tok:Token = null;
    var end = tokens.length - 1;
    var min:Int = null;
    var max:Int = null;

    while (index <= end) {
      var check = tokens[index];
      index++;
      switch check.type {
        case TokNewline: 
          line++;
          tok = check;
          min = check.pos.max;
          max = check.pos.max;
          if (line == lineNumber) break;
        default:
      }
    }

    if (tok != null) while (index <= end) {
      var tok = tokens[index];
      index++;
      switch tok.type {
        case TokNewline: 
          max = tok.pos.min;
          break;
        default:
      }
    }

    return if (tok == null) null else {
      line: line,
      newlinePos: tok.pos,
      pos: { min: min, max: max, file: tok.pos.file }
    };
  }

  public static function getLineAt(tokens:Array<Token>, at:Int):{ line:Int, newlinePos:Position, pos:Position } {
    var index = 0;
    var end = tokens.length - 1;
    var line = 1;
    var tok:Token = null;
    var min:Int = null;
    var max:Int = null;
    
    while (index <= end) {
      var check = tokens[index];
      index++;
      switch check.type {
        case TokNewline: 
          line++;
          tok = check;
          min = check.pos.max;
          max = check.pos.max;
        default:
      }
      if (check.pos.min >= at) break;
    }

    if (tok == null) {
      tok = tokens[0];
      index++;
      min = 0;
      max = 0;
    }

    if (tok != null) while (index <= end) {
      var tok = tokens[index];
      index++;
      switch tok.type {
        case TokNewline: 
          max = tok.pos.min;
          break;
        default:
      }
    }

    return if (tok == null) null else {
      line: line,
      newlinePos: tok.pos,
      pos: { min: min, max: max, file: tok.pos.file }
    };
  }

  public static function getPosRelativeToNewline(tokens:Array<Token>, pos:Position):Position {
    var line = getLineAt(tokens, pos.min);
    if (line.line == 1) return pos;
    return {
      min: pos.min - line.newlinePos.max,
      max: pos.max - line.newlinePos.max,
      file: pos.file 
    };
  }
}