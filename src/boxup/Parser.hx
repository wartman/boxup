package boxup;

import boxup.Node;

using StringTools;

class Parser {
  final source:Source;
  var position:Int = 0;

  public function new(source) {
    this.source = source.fixLineEndings();
  }

  public function parse():Array<Node> {
    position = 0;

    return [ 
      while (!isAtEnd()) parseRoot(0)
    ].filter(n -> n != null);
  }

  public function parseRoot(?indent:Int = 0):Node {
    if (isAtEnd()) return null;
    if (isNewline(peek())) {
      advance();
      return parseRoot(0);
    }
    if (match(' ')) return parseRoot(indent + 1);
    if (match('[')) {
      if (match('!')) return parseComment(indent);
      return parseBlock(indent);
    }
    return parseParagraph(indent);
  }

  function parseRootInline(indent:Int) {
    if (isAtEnd() || isNewline(peek())) return null;
    ignoreWhitespace();
    if (match('[')) {
      if (match('!')) return parseComment(indent);
      return parseBlock(indent);
    }
    return parseParagraph(indent);
  }

  function parseComment(indent:Int) {
    // For the moment, we just throw away comments.
    readWhile(() -> !checkUnescaped(']'));
    consume(']');
    return parseRoot(indent);
  }

  function parseBlock(indent:Int, isTag:Bool = false):Node {
    ignoreWhitespace();

    var start = position;
    var blockName = blockIdentifier();
    var end = position;
    var properties:Array<Property> = [];

    ignoreWhitespace();

    if (!check(']')) {
      do {
        ignoreWhitespaceAndNewline();
        if (check(']')) break; // this is a hack :P
        properties.push(parseProperty(true));
      } while (!isAtEnd() && !check(']') && (isWhitespace(peek()) || isNewline(peek())));
    }

    consume(']');
    
    var children:Array<Node> = [];
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

    // If this block is a tag (that is, it's part of a tag like
    // `<foo>[Link url = "bar"]`) then don't parse children.
    if (!isTag) {
      ignoreWhitespace();
      if (!isNewline(peek())) {
        children.push(parseRootInline(indent)); // Allow children to follow on the same line
      } else if (isPropertyBlock(indent)) while (checkIndent()) {
        properties.push(parseProperty(false));
      } else while (checkIndent()) switch parseRoot(childIndent) {
        case null:
        case child: children.push(child);
      };
    }

    return {
      type: Block(blockName),
      isTag: isTag,
      textContent: null,
      properties: properties,
      children: children,
      pos: {
        min: start,
        max: end,
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

  function parseProperty(isInBlockDecl:Bool = true):Property {
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

  function parseValue(isInBlockDecl:Bool):Value {
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
  
  function parseParagraph(indent:Int):Node {
    var start = position;
    var children:Array<Node> = [];

    do {
      if (checkUnescaped('<')) {
        consume('<');
        children.push(parseTaggedBlock());
      } else if (checkUnescaped('/')) {
        consume('/');
        children.push(parseDecoration(BItalic, '/'));
      } else if (checkUnescaped('*')) {
        consume('*');
        children.push(parseDecoration(BBold, '*'));
      } else if (checkUnescaped('_')) {
        consume('_');
        children.push(parseDecoration(BUnderlined, '_'));
      } else if (checkUnescaped('`')) {
        consume('`');
        children.push(parseDecoration(BRaw, '`'));
      } else {
        children.push(parseTextPart(indent));
      }
    } while (!isAtEnd() && !isNewline(peek()));

    return {
      type: Paragraph,
      textContent: null,
      children: children,
      properties: [],
      pos: {
        min: start,
        max: position,
        file: source.filename
      } 
    };
  }

  function parseDecoration(name:Builtin, delimiter:String):Node {
    var start = position;
    var text = readWhile(() -> !checkUnescaped(delimiter));
    var pos:Position = {
      min: start,
      max: position,
      file: source.filename
    };
    consume(delimiter);
    return {
      type: Block(name),
      textContent: null,
      properties: [],
      children: [
        {
          type: Text,
          textContent: text,
          properties: [],
          children: [],
          pos: pos
        }
      ],
      pos: pos
    }
  }

  function parseTaggedBlock():Node {
    var start = position;
    var value = readWhile(() -> !check('>'));
    var tag:Value = {
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

    var block = parseBlock(0, true);
    block.children.push({
      type: Text,
      textContent: tag.value,
      children: [],
      properties: [],
      pos: tag.pos
    });
    return block;
  }

  function parseTextPart(indent:Int):Node {
    var start = position;
    var read = () -> readWhile(() -> !checkAnyUnescaped([ '<', '*', '/', '_', '`' ]) && !isNewline(peek()));
    var text = read();

    // If we don't skip a line after a newline, treat it as part of the
    // current paragraph. We also need to check to make sure that the
    // line actually has some content -- there might be indentation, but
    // nothing actually on the line.
    //
    // This right here is why I dislike significant whitespace, but anyway.
    function readNext() if (!isAtEnd()) {
      var pre = position;
      if (isNewline(peek())) {
        advance();
        if (findIndentWithoutNewline() >= indent) {
          var part = read();
          if (part.length == 0) {
            position = pre;
          } else {
            text = text.trim() + ' ' + part;
            readNext();
          }
        } else {
          position = pre;
        }
      } else {
        position = pre;
      }
    }

    readNext();

    return {
      type: Text,
      textContent: text,
      properties: [],
      children: [],
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
    Check if any of the values are coming up next (and do NOT consume it).
  **/
  function checkAnyUnescaped(values:Array<String>) {
    for (v in values) {
      if (checkUnescaped(v)) return true;
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

  function peekNext() {
    return source.content.charAt(position + 1);
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
    if (c == 'true' || c == 'false') return 'Bool';
    var isInt = () -> {
      for (i in 0...c.length) {
        if (isWhitespace(c.charAt(i))) continue;
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
    return new Error(msg, {
      min: min,
      max: max,
      file: source.filename
    });
  }
}
