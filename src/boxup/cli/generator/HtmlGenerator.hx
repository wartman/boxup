package boxup.cli.generator;

using StringTools;

typedef HtmlChildren = ()->Array<String>;

typedef HtmlOptions = {
  public final noIndent:Bool;
}

/*
  A HTML generator -- expects the Markup definition by default,
  but can be easily overriden.
*/
class HtmlGenerator implements Generator<String> {
  var indent:Int = 0;

  public function new() {}

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
      case Block('Section'):
        el('section', [ 
          'class' => 'section', 
          'id' => node.getProperty('id') 
        ], generateNodes(node.children));
      case Block('Note'):
        el('aside', [ 
          'class' => 'note', 
          'id' => node.getProperty('id') 
        ], generateNodes(node.children));
      case Block('Link'):
        el('a', [ 
          'href' => node.getProperty('href') 
        ], generateNodes(node.children, false));
      case Block('Image'):
        el('img', [
          'src' => node.getProperty('src'),
          'alt' => node.getProperty('alt')
        ], null);
      case Block('Header'):
        el('header', [], generateNodes(node.children));
      case Block('Title'):
        el(switch node.getProperty('type') {
          case 'Main': 'h1';
          case 'Secondary': 'h2';
          default: 'h3';
        }, [], generateNodes(node.children, false), { noIndent: true });
      case Block('List'): 
        el(switch node.getProperty('type') {
          case 'Ordered': 'ol';
          default: 'ul';
        }, [], generateNodes(node.children));
      case Block('Item'):
        el('li', [], generateNodes(node.children));
      case Paragraph if (wrapParagraph):
        el('p', [], generateNodes(node.children), { noIndent: true });
      case Paragraph:
        node.children.map(n -> generateNode(n, false)).join('');
      case Text:
        node.textContent.htmlEscape();
      case Block(name):
        el('div', [ 'class' => name.toLowerCase() ], generateNodes(node.children));
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
