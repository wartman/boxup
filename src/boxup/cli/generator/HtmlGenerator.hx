package boxup.cli.generator;

import boxup.Builtin;

using StringTools;
using Lambda;

typedef HtmlChildren = ()->Array<String>;

typedef HtmlOptions = {
  public final noIndent:Bool;
}

/*
  A HTML generator. Uses `[RenderHint.*]` to figure out how to handle
  blocks, but you can easily override with your own logic.
*/
class HtmlGenerator implements Generator<String> {
  var indent:Int = 0;
  final definition:Definition;

  public function new(definition) {
    this.definition = definition;
  }

  public function generate(nodes:Array<Node>):Outcome<String> {
    indent = 0;
    return Ok(wrap(nodes));
  }

  function wrap(nodes:Array<Node>) {
    return [
      '<!doctype HTML>',
      el('html', [], () -> [
        el('head', [], generateHead(nodes)),
        el('body', [], generateNodes(nodes))
      ]) 
    ].join('\n');
  }

  function generateHead(nodes:Array<Node>):HtmlChildren {
    return () -> [
      el('title', [], () -> [ 'Boxup Document' ], { noIndent: true })
    ];
  }

  function generateNode(node:Node, wrapParagraph:Bool = true) {
    return switch node.type {
      case Paragraph if (wrapParagraph):
        el('p', [], generateNodes(node.children), { noIndent: true });
      case Paragraph:
        node.children.map(n -> generateNode(n, false)).join('');
      case Text:
        node.textContent.htmlEscape();
      case Block(BBold):
        el('b', [], generateNodes(node.children), { noIndent: true });
      case Block(BItalic) | Block(BUnderlined):
        el('i', [], generateNodes(node.children), { noIndent: true });
      case Block(BRaw):
        el('pre', [], generateNodes(node.children));
      case Block(name):
        var hint = switch definition.getBlock(name) {
          case null: 'Section';
          case def: def.renderHint;
        }
        switch hint {
          case 'Header':
            el('h1', [ 'class' => generateClassName(name, node) ], generateNodes(node.children, false));
          case 'SubHeader':
            el('h2', [ 'class' => generateClassName(name, node) ], generateNodes(node.children, true));
          case 'ListContainer':
            el('ul', [ 'class' => generateClassName(name, node) ], generateNodes(node.children));
          case 'ListItem': 
            el('li', [ 'class' => generateClassName(name, node) ], generateNodes(node.children, false));
          case 'Link':
            el('a', [
              'href' => node.getProperty('href')
            ], generateNodes(node.children));
          case 'Image':
            el('img', [
              'src' => node.getProperty('src'),
              'alt' => node.getProperty('alt')
            ]);
          default:
            el('div', [ 'class' => generateClassName(name, node) ], generateNodes(node.children));
        }
    }
  }

  function generateClassName(name:String, node:Node) {
    var def = definition.getBlock(name);
    var className = name.toLowerCase();

    if (def == null) return className;

    var idProperty = def.getIdProperty();
    if (idProperty == null) return className;

    return switch node.getProperty(idProperty) {
      case null: className;
      case id: '${className} ${className}--${id.toLowerCase()}';
    }
  }

  function generateNodes(nodes:Array<Node>, wrapParagraph:Bool = true) {
    return () -> nodes.map(node -> generateNode(node, wrapParagraph));
  }

  function fragment(children:HtmlChildren) {
    var result = [ for (index => child in children()) {
      if (index != 0) 
        getPadding() + child;
      else 
        child;
    } ].join('\n');
    return result;
  }

  function el(
    tag:String,
    props:Map<String, String>,
    ?children:HtmlChildren, 
    ?options:HtmlOptions
  ) {
    if (options == null) options = { noIndent: false };
    var out = '<$tag';
    var props = [ for (key => value in props) 
      if (value != null) '$key="$value"' else null ].filter(v -> v != null);
    if (props.length > 0) out += ' ${props.join(' ')}';
    return if (children != null && options.noIndent) {
      out + '>${children().join('')}</$tag>';
    } else if (children != null) {
      addIndent();
      var result = children().map(c -> getPadding() + c).join('\n');
      removeIndent();
      out + '>\n' + result + '\n${getPadding()}</$tag>';
    } else 
      out + '/>';
  }

  function addIndent() {
    indent++;
  }

  function removeIndent() {
    indent--;
    if (indent < 0) indent = 0;
  }

  function getPadding() {
    if (indent == 0) return '';
    return [ for (_ in 0...indent) '  ' ].join('');
  }
}
