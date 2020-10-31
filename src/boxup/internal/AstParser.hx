package boxup.internal;

using StringTools;

class AstParser {
  final source:Source;
  var position:Int = 0;

  public function new(source) {
    this.source = source;
  }

  public function parse():AstNode {
    position = 0;

    var children:Array<AstNode> = [ 
      while (!isAtEnd()) parseRoot(0)
    ].filter(n -> n != null);
    
    return {
      block: Builtin.document,
      children: children,
      properties: [],
      pos: {
        min: 0,
        max: position,
        file: source.filename
      }
    };
  }

  public function parseRoot(?indent:Int = 0):AstNode {
    if (isAtEnd()) return null;
    if (isNewline(peek())) {
      advance();
      return parseRoot(0);
    }
    if (match(' ')) return parseRoot(indent + 1);
    if (match('[')) return parseBlock(indent);
    return parseParagraph(indent);
  }

  function parseBlock(indent:Int, isInline:Bool = false):AstNode {
    ignoreWhitespace();

    var start = position;
    var blockName = blockIdentifier();
    var properties:Array<AstProperty> = [];

    ignoreWhitespace();

    if (!check(']')) {
      do {
        ignoreWhitespaceAndNewline();
        if (check(']')) break; // this is a hack :P
        properties.push(parseProperty(true));
      } while (!isAtEnd() && !check(']') && (isWhitespace(peek()) || isNewline(peek())));
    }

    consume(']');
    
    var children:Array<AstNode> = [];
    var childIndent:Int = 0;
    inline function checkIndent() {
      var prev:Int = position;
      if (!isAtEnd() && ((childIndent = findIndent()) > indent)) {
        return true;
      } else {
        position = prev;
        return false;
      }
    }

    // If this block is inline (that is, it's part of a tag like
    // `<foo>[Link url = "bar"]`) then don't parse children.
    if (!isInline) {
      ignoreWhitespace();
      if (!isNewline(peek())) {
        children.push(parseInlineText());
      } else if (isPropertyBlock(indent)) while (checkIndent()) {
        properties.push(parseProperty(false));
      } else while (checkIndent()) switch parseRoot(childIndent) {
        case null:
        case child: children.push(child);
      };
    }

    return {
      block: blockName,
      properties: properties,
      children: children,
      pos: {
        min: start,
        max: position,
        file: source.filename
      }
    };
  }

  function isPropertyBlock(indent:Int) {
    var start = position;
    if (findIndent() > indent && identifier().length > 0) {
      ignoreWhitespace();
      if (check('=')) {
        position = start;
        return true;
      }
    }
    position = start;
    return false;
  }

  function parseProperty(isInBlockDecl:Bool = true):AstProperty {
    var start = position;
    var name = identifier();
    ignoreWhitespace();
    consume('=');
    ignoreWhitespace();
    var value = parseValue(isInBlockDecl);

    return {
      name: name,
      value: value,
      pos: {
        min: start,
        max: position,
        file: source.filename
      }
    };
  }

  function parseValue(isInBlockDecl:Bool):AstValue {
    var start = position; 
    var value = if (match('"')) {
      string('"');
    } else if (match("'")) {
      string("'");
    } else if (isInBlockDecl) {
      // Is inside a block's `[]`, which means we can't just
      // read everything till a newline.
      readWhile(() -> isAlphaNumeric(peek()));
    } else {
      // Is not inside a block's `[]`, which means we can just
      // read everything up to the newline.
      readWhile(() -> !isNewline(peek()));
    }

    return {
      type: getType(value),
      value: value,
      pos: {
        min: start,
        max: position,
        file: source.filename
      }
    };
  }

  function parseParagraph(indent:Int):AstNode {
    var start = position;
    var children:Array<AstNode> = [];

    do {
      if (checkUnescaped('<')) {
        consume('<');
        children.push(parseTaggedBlock());
      } else {
        children.push(parseTextPart(indent));
      }
    } while (!isAtEnd() && !isNewline(peek()));

    return {
      block: Builtin.paragraph,
      children: children,
      properties: [],
      pos: {
        min: start,
        max: position,
        file: source.filename
      } 
    };
  }

  function parseTaggedBlock():AstNode {
    var start = position;
    var value = readWhile(() -> !check('>'));
    var tag:AstValue = {
      type: 'String',
      value: value,
      pos: {
        min: start,
        max: position,
        file: source.filename
      }
    };

    consume('>');
    consume('[');

    var block =  parseBlock(0, true);

    return {
      block: Builtin.tagged,
      properties: [
        {
          name: '__tagged',
          value: tag,
          pos: tag.pos
        }
      ],
      children: [ block ],
      pos: {
        min: start,
        max: position,
        file: source.filename
      }
    };
  }

  function parseTextPart(indent:Int):AstNode {
    var start = position;
    var read = () -> readWhile(() -> !checkUnescaped('<') && !isNewline(peek()));
    var text = read();

    // If we don't skip a line after a newline, treat it as part of the
    // current paragraph. 
    function readNext() if (!isAtEnd()) {
      var pre = position;
      if (isNewline(peek())) {
        advance();
        if (findIndentWithoutNewline() >= indent) {
          text = text.trim() + ' ' + read();
          readNext();
        } else {
          position = pre;
        }
      } else {
        position = pre;
      }
    }

    readNext();

    var value:AstValue = {
      value: text,
      type: 'String',
      pos: {
        min: start,
        max: position,
        file: source.filename
      }
    };
    return {
      block: Builtin.text,
      properties: [
        { 
          name: '__text',
          value: value,
          pos: value.pos
        }
      ],
      children: [],
      pos: {
        min: start,
        max: position,
        file: source.filename
      }
    };
  }

  function parseInlineText():AstNode {
    var start = position;
    var text = readWhile(() -> !isNewline(peek()));
    var pos:Position = {
      min: start,
      max: position,
      file: source.filename
    };
    
    return {
      block: Builtin.inlineText,
      children: [],
      properties: [
        {
          name: '__text',
          pos: pos,
          value: {
            type: 'String',
            value: text,
            pos: pos
          }
        }
      ],
      pos: {
        min: start,
        max: position,
        file: source.filename
      } 
    };
  }

  function blockIdentifier() {
    if (!isUcAlpha(peek())) {
      throw error('Expected an uppercase identifier', position, position + 1);
    }
    return identifier();
  }

  function identifier() {
    return readWhile(() -> isAlphaNumeric(peek()));
  }
  
  function string(delimiter:String) {
    var out = '';
    var start = position;

    while (!isAtEnd() && !match(delimiter)) {
      out += advance();
      if (previous() == '\\' && !isAtEnd()) {
        out += '\\${advance()}';
      }
    }

    if (isAtEnd()) 
      throw error('Unterminated string', start, position);
    
    return out;
  }

  function findIndentWithoutNewline() {
    var found = 0;
    while (!isAtEnd() && isWhitespace(peek())) {
      advance();
      found++;
    }
    return found;
  }

  function findIndent() {
    var found = findIndentWithoutNewline();
    if (!isAtEnd() && isNewline(peek())) {
      advance();
      return findIndent();
    }
    return found;
  }

  /**
    Check a value AND consume it.
  **/
  function match(value:String) {
    if (check(value)) {
      position = position + value.length;
      return true;
    }
    return false;
  }

  /**
    Check against a number of values value AND consume it.
  **/
  function matchAny(values:Array<String>) {
    for (v in values) {
      if (match(v)) return true;
    }
    return false;
  }

  /**
    Check if the value is coming up next (and do NOT consume it).
  **/
  function check(value:String) {
    var found = source.content.substr(position, value.length);
    return found == value;
  }

  /**
    Check if any of the values are coming up next (and do NOT consume it).
  **/
  function checkAny(values:Array<String>) {
    for (v in values) {
      if (check(v)) return true;
    }
    return false;
  }

  /**
    Check an item, but ensure it isn't escaped.
  **/
  function checkUnescaped(item:String) {
    if (check(item)) {
      if (previous() == '\\') return false;
      return true;
    }
    return false;
  }

  function consume(value:String) {
    if (!match(value)) throw expected(value);
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

  function isWhitespace(c:String) {
    return c == ' ' || c == '\r' || c == '\t';
  }

  function ignoreWhitespace() {
    readWhile(() -> isWhitespace(peek()));
  }

  function isNewline(c:String) {
    return c == '\n';
  }

  function ignoreWhitespaceAndNewline() {
    readWhile(() -> isWhitespace(peek()) || isNewline(peek()));
  }

  function isDigit(c:String):Bool {
    return c >= '0' && c <= '9';
  }

  function isUcAlpha(c:String):Bool {
    return (c >= 'A' && c <= 'Z');
  }

  function isAlpha(c:String):Bool {
    return (c >= 'a' && c <= 'z') ||
           (c >= 'A' && c <= 'Z') ||
            c == '_';
  }

  function isAlphaNumeric(c:String) {
    return isAlpha(c) || isDigit(c);
  }
  
  function getType(c:String) {
    var isInt = () -> {
      for (i in 0...c.length) {
        if (!isDigit(c.charAt(i))) return false;
      }
      return true;
    }
    var isFloat = () -> {
      for (i in 0...c.length) {
        if (!isDigit(c.charAt(i)) || c.charAt(i) != '.') {
          return false;
        }
      }
      return true;
    }
    return if (isInt()) 'Int' else if (isFloat()) 'Float' else 'String';
  }

  function readWhile(compare:()->Bool):String {
    var out = [ while (!isAtEnd() && compare()) advance() ];
    return out.join('');
  }

  function isAtEnd() {
    return position >= source.content.length;
  }

  function reject(s:String) {
    return error('Unexpected [${s}]', position - s.length, position);
  }

  function expected(s:String) {
    return error('Expected [${s}]', position, position + 1);
  }

  function error(msg:String, min:Int, max:Int) {
    return new ParserException(msg, {
      min: min,
      max: max,
      file: source.filename
    });
  }
}