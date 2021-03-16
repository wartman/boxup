package boxup;

using Lambda;
using StringTools;

class Source {
  public final filename:String;
  public final content:String;
  var _tokens:Outcome<Array<Token>>;
  public var tokens(get, never):Outcome<Array<Token>>;
  function get_tokens() {
    if (_tokens == null) {
      _tokens = new Scanner(this).scan();
    }
    return _tokens;
  }

  public function new(filename, content) {
    this.filename = filename;
    this.content = content;
  }

  public function getTokenByPos(pos:Position) {
    return tokens.sure().find(t -> t.pos.min == pos.min); 
  }

  // @todo: Lot of repeating myself here. Simplify this!!

  public function getLine(lineNumber:Int):{ line:Int, newlinePos:Position, pos:Position } {
    if (lineNumber == 1) return getLineAt(0);

    var line = 1;
    var index = 0;
    var tok:Token = null;
    var toks = tokens.sure();
    var end = toks.length - 1;
    var min:Int = null;
    var max:Int = null;

    while (index <= end) {
      var check = toks[index];
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
      var tok = toks[index];
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
      pos: { min: min, max: max, file: filename }
    };
  }

  public function getLineAt(at:Int):{ line:Int, newlinePos:Position, pos:Position } {
    var index = 0;
    var toks = tokens.sure();
    var end = toks.length - 1;
    var line = 1;
    var tok:Token = null;
    var min:Int = null;
    var max:Int = null;
    
    while (index <= end) {
      var check = toks[index];
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
      tok = toks[0];
      index++;
      min = 0;
      max = 0;
    }

    if (tok != null) while (index <= end) {
      var tok = toks[index];
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
      pos: { min: min, max: max, file: filename }
    };
  }

  public function getPosRelativeToNewline(pos:Position):Position {
    var line = getLineAt(pos.min);
    if (line.line == 1) return pos;
    return {
      min: pos.min - line.newlinePos.max,
      max: pos.max - line.newlinePos.max,
      file: filename 
    };
  }
}
