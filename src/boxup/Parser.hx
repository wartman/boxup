package boxup;

import boxup.Node;

using StringTools;
using boxup.TokenTools;

class Parser {
  final tokens:Array<Token>;
  var position:Int = 0;

  public function new(tokens) {
    this.tokens = tokens;
  }

  public function parse():Outcome<Array<Node>> {
    position = 0;
    return try {
      Ok([ 
        while (!isAtEnd()) parseRoot(0)
      ].filter(n -> n != null));
    } catch (e:Error) {
      Fail(e);
    } catch (e) {
      Fail(new Error(e.details(), {
        min: 0,
        max: 0,
        file: tokens.length != 0 ? tokens[0].pos.file : '<unknown>'
      }));
    }
  }

  function parseRoot(indent:Int = 0):Node {
    if (isAtEnd()) return null;
    if (match(TokNewline)) return parseRoot(0);
    if (match(TokWhitespace)) return parseRoot(indent + 1);
    if (match(TokCommentStart)) { 
      ignoreComment();
      return parseRoot(indent);
    }
    if (match(TokOpenBracket)) return parseBlock(indent);
    return parseParagraph(indent);
  }

  function parseRootInline(indent:Int) {
    if (isAtEnd() || isNewline(peek())) return null;
    ignoreWhitespace();
    if (match(TokCommentStart)) {
      ignoreComment();
      return parseRootInline(indent);
    }
    if (match(TokOpenBracket)) return parseBlock(indent);
    return parseParagraph(indent);
  }

  function parseBlock(indent:Int, isTag:Bool = false):Node {
    ignoreWhitespace();

    var properties:Array<Property> = [];
    var children:Array<Node> = [];
    var id:Value = null;
    var blockName = switch symbol() {
      case null: 
        var name = blockIdentifier();
        if (match(TokSlash)) {
          id = parseValue(true);
          if (id == null) throw error('Expected an ID', peek().pos);
        }
        name;
      case sym:
        id = parseValue(true);
        sym;
    }

    ignoreWhitespace();

    if (!check(TokCloseBracket)) {
      do {
        ignoreWhitespaceAndNewline();
        if (check(TokCloseBracket)) break;
        properties.push(parseProperty(true));
      } while (
        !isAtEnd()
        && !check(TokCloseBracket)
        && (isWhitespace(peek()) || isNewline(peek()))
      );
    }

    consume(TokCloseBracket);
    ignoreWhitespace();

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
        if (checkIdentifier()) properties.push(parseProperty(false));
      } else while (checkIndent()) switch parseRoot(childIndent) {
        case null:
        case child: children.push(child);
      };
    }

    return {
      type: Block(blockName.value),
      id: id,
      isTag: isTag,
      properties: properties,
      children: children,
      pos: blockName.pos
    }
  }

  function isPropertyBlock(indent:Int) {
    var start = position;
    if (findIndent() > indent && identifier() != null) {
      ignoreWhitespace();
      if (check(TokEquals)) {
        position = start;
        return true;
      }
    }
    position = start;
    return false;
  }

  function parseProperty(isInBlockDecl:Bool = true):Property {
    var name = identifier();

    if (name == null) {
      throw error('Expected an identifier', peek().pos);
    }
    
    ignoreWhitespace();
    consume(TokEquals);
    ignoreWhitespace();

    var value = parseValue(isInBlockDecl);

    if (value == null) {
      throw error('Expected a value', peek().pos);
    }

    return {
      name: name.value,
      value: value,
      pos: name.pos
    };
  }

  function parseValue(isInBlockDecl:Bool):Null<Value> {
    var tok = if (match(TokSingleQuote)) {
      parseString(TokSingleQuote);
    } else if (match(TokDoubleQuote)) {
      parseString(TokDoubleQuote);
    } else if (isInBlockDecl) {
      readWhile(() -> check(TokText)).merge();
    } else {
      readWhile(() -> !isNewline(peek())).merge();
    }

    if (tok == null) return null;

    return {
      type: getType(tok.value),
      value: tok.value,
      pos: tok.pos
    };
  }

  function parseParagraph(indent:Int):Node {
    var start = peek();
    var children:Array<Node> = [];

    do {
      if (match(TokOpenAngleBracket))
        children.push(parseTaggedBlock());
      else if (match(TokUnderline))
        children.push(parseDecoration(BItalic, TokUnderline));
      else if (match(TokStar))
        children.push(parseDecoration(BBold, TokStar));
      else if (match(TokRaw))
        children.push(parseDecoration(BRaw, TokRaw));
      else
        children.push(parseTextPart(indent));
    } while (!isAtEnd() && !isNewline(peek()));

    return {
      type: Paragraph,
      children: children.filter(c -> c != null),
      properties: [],
      pos: start.getMergedPos(previous())
    }
  }

  function parseDecoration(name:Builtin, delimiter:TokenType):Node {
    var tok = readWhile(() -> !check(delimiter)).merge();
    consume(delimiter);
    return {
      type: Block(name),
      properties: [],
      children: [
        {
          type: Text,
          textContent: tok.value,
          properties: [],
          children: [],
          pos: tok.pos
        }
      ],
      pos: tok.pos
    }
  }

  function parseTaggedBlock() {
    var tagged = readWhile(() -> !check(TokCloseAngleBracket)).merge();

    consume(TokCloseAngleBracket);
    consume(TokOpenBracket);

    var block = parseBlock(0, true);
    block.children.push({
      type: Text,
      textContent: tagged.value,
      children: [],
      properties: [],
      pos: tagged.pos
    });
    return block;
  }

  function parseTextPart(indent:Int):Node {
    var read = () -> readWhile(() -> 
      !checkAny([ 
        TokOpenAngleBracket,
        TokStar,
        TokUnderline,
        TokRaw,
        TokNewline
      ])
    ).merge();
    var out = [ read() ];

    function readNext() if (!isAtEnd()) {
      var pre = position;
      if (isNewline(peek())) {
        advance();
        if (findIndentWithoutNewline() >= indent) {
          // Bail if we see a block after a newline.
          if (isBlockStart()) {
            position = pre;
          } else {
            var part = read();
            if (part == null || part.value.length == 0) {
              position = pre;
            } else {
              out.push({
                type: part.type,
                value: ' ' + part.value.trim(),
                pos: part.pos
              });
              readNext();
            }
          }
        } else {
          position = pre;
        }
      } else {
        position = pre;
      }
    }

    readNext();

    var tok = out.merge();

    return {
      type: Text,
      textContent: tok.value,
      properties: [],
      children: [],
      pos: tok.pos
    };
  }

  function ignoreComment() {
    // Todo: allow nesting.
    readWhile(() -> !check(TokCommentEnd));
    if (!isAtEnd()) consume(TokCommentEnd);
  }
  
  function parseString(delimiter:TokenType):Token{
    var out = readWhile(() -> !check(delimiter)).merge();
    
    if (isAtEnd()) {
      throw error('Unterminated string', out.pos);
    }

    consume(delimiter);
    return out;
  }

  function isBlockStart() {
    return check(TokOpenBracket);
  }

  function symbol():Null<Token> {
    return switch peek().type {
      case TokBang | TokAt | TokHash 
          | TokPercent | TokDollar | TokAmp 
          | TokCarat | TokDash | TokPlus
          | TokQuestion | TokOpenAngleBracket
          | TokCloseAngleBracket | TokStar
          | TokColon | TokDot: advance();
      default: null;
    }
  }

  function blockIdentifier() {
    if (!checkTokenValueStarts(peek(), isUcAlpha)) {
      throw error('Expected an uppercase identifier', peek().pos);
    }
    return identifier();
  }

  function identifier() {
    return readWhile(() -> checkTokenValue(peek(), isAlphaNumeric)).merge();
  }

  function checkIdentifier() {
    return checkTokenValue(peek(), isAlphaNumeric);
  }
  
  // @todo: add dates too! 
  function getType(c:String) {
    if (c == 'true' || c == 'false') return 'Bool';
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

  function ignoreWhitespace() {
    readWhile(() -> isWhitespace(peek()));
  }

  function ignoreWhitespaceAndNewline() {
    readWhile(() -> isWhitespace(peek()) || isNewline(peek()));
  }
  
  function isNewline(token:Token) {
    return token.type == TokNewline;
  }

  function isWhitespace(token:Token) {
    return token.type == TokWhitespace;
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

  function checkTokenValueStarts(token:Token, comp:(c:String)->Bool):Bool {
    if (token.value.length == 0) return false;
    return comp(token.value.charAt(0));
  }

  function checkTokenValue(token:Token, comp:(c:String)->Bool):Bool {
    if (token.value.length == 0) return false;
    for (pos in 0...token.value.length) {
      if (!comp(token.value.charAt(pos))) return false;
    }
    return true;
  }

  inline function readWhile(compare:()->Bool):Array<Token> {
    return [ while (!isAtEnd() && compare()) advance() ];
  }

  inline function consume(type:TokenType) {
    if (!match(type)) throw error('Expected a ${type}', peek().pos);
  }

  function match(type:TokenType) {
    if (check(type)) {
      advance();
      return true;
    }
    return false;
  }

  inline function check(type:TokenType) {
    return peek().type == type;
  }

  function checkAny(types:Array<TokenType>) {
    for (type in types) {
      if (check(type)) return true;
    }
    return false;
  }

  inline function peek() {
    return tokens[position];
  }

  inline function previous() {
    return tokens[position - 1];
  }

  function advance() {
    if (!isAtEnd()) position++;
    return previous();
  }

  function isAtEnd() {
    return position >= tokens.length || peek().type == TokEof;
  }

  function error(msg:String, pos:Position) {
    return new Error(msg, pos);
  }
}