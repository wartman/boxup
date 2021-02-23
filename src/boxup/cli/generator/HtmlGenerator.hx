package boxup.cli.generator;

using StringTools;

/*
  A HTML generator -- expects the Markup definition.

  @todo: Allow this to be extended? Could just override
         `generateNode` for the user's needs.
*/
class HtmlGenerator implements Generator<String> {
  public function new() {}

  public function generate(nodes:Array<Node>):String {
    return wrap(nodes.map(n -> generateNode(n)).join(''));
  }

  // @todo: Allow the user to setup the <head>.
  function wrap(body:String) {
    return [
      '<!doctype HTML>',
      // @todo: head
      '<html><body>',
      body,
      '</body></html>'
    ].join('');
  }

  function generateNode(node:Node, wrapParagraph:Bool = true) {
    return switch node.type {
      case Block('Section'):
        el('section', [ 'class' => 'section', 'id' => node.getProperty('id') ], node.children);
      case Block('Note'):
        el('aside', [ 'class' => 'note', 'id' => node.getProperty('id') ], node.children);
      case Block('Link'):
        el('a', [ 'href' => node.getProperty('href') ], node.children, false);
      case Block('Image'):
        el('img', [
          'src' => node.getProperty('src'),
          'alt' => node.getProperty('alt')
        ], null);
      case Block('Header'):
        el('header', [], node.children);
      case Block('Title'):
        el(switch node.getProperty('type') {
          case 'Main': 'h1';
          case 'Secondary': 'h2';
          default: 'h3';
        }, [], node.children, false);
      case Block('List'): 
        el(switch node.getProperty('type') {
          case 'Ordered': 'ol';
          default: 'ul';
        }, [], node.children);
      case Block('Item') | Arrow:
        el('li', [], node.children);
      case Paragraph if (wrapParagraph):
        el('p', [], node.children);
      case Paragraph:
        node.children.map(n -> generateNode(n, false)).join('');
      case Text:
        node.textContent.htmlEscape();
      case Block(name):
        el('div', [ 'class' => name.toLowerCase() ], node.children);
    }
  }

  function el(tag:String, props:Map<String, String>, children:Array<Node>, wrapParagraph:Bool = true) {
    var out = '<$tag';
    var props = [ for (key => value in props) 
      if (value != null) '$key="$value"' else null ].filter(v -> v != null);
    if (props.length > 0) out += ' ${props.join(' ')}';
    return if (children != null) 
      out + '>' + children.map(n -> generateNode(n, wrapParagraph)).join('') + '</$tag>';
    else 
      out + '/>';
  }
}
