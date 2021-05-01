package boxup.cli.generator;

import haxe.DynamicAccess;
import haxe.Template;
import boxup.Builtin;
import boxup.definition.Definition;

using StringTools;
using Lambda;
using boxup.cli.generator.GeneratorTools;

typedef HtmlChildren = ()->Array<String>;

typedef HtmlOptions = {
  public final noIndent:Bool;
}

/**
  You can extend this generator with your own logic by overriding the relevant
  functions, but you can generally implement a complete HTML generator
  just using Boxup defintion files and `[Meta/html]`.

  The HtmlGenerator has several builtin behaviors you can set via
  `[Meta/html renderHint = *]`. These include `Header`, `Link`, `ListContainer`,
  `ListItem` etc.

  For more complex scenerios, you can use `[Meta/html renderHint=Template]`.
  This will require you to define a `template` property as well, which
  will be passed to `haxe.Template` to render the Block. Inside the template
  you'll have access to all the properties in the current node as well
  as a special `children` and `__indent__` property provided by the compiler.

  For example:

  ```boxup
  [Block/MenuItem]
    [Meta/html]
      renderHint = Template
      wrapParagraph = false
      template = '<li><a href="::href::.html">::children::</a></li>'
    [IdProperty/href]
    [Child/Paragraph]
  ```

  Or for a more complex example that spans several lines, use Boxup's 
  multiline string syntax (which will preserve indentation):

  ```boxup
  [Block/Section]
    [Meta/html]
      renderHint=Template
      template = |
        <section class="section">
          ::if title::<h3 class="section-title">::title::</h3>::end::
          ::children::
        </section>
      |
    [IdProperty/title]
    [Child/Paragraph]
    [Child/Header]
    [Child/Title]
    [Child/SubTitle]
    [Child/Link]
    [Child/List]
    [Child/Image]
  ```

  More complete documentation about all the available `[Meta/html]` properties
  will be coming soon.
**/
class HtmlGenerator implements Generator<String> {
  var indent:Int = 0;
  final definition:Definition;

  public function new(definition) {
    this.definition = definition;
  }

  public function generate(nodes:Array<Node>, source:Source):Result<String> {
    indent = 0;
    return Ok(wrap(nodes));
  }

  function wrap(nodes:Array<Node>) {
    return [
      '<!doctype HTML>',
      el('html', [], () -> [
        el('head', [], generateHead(nodes)),
        el('body', [], () -> [
          fragment(() -> definition.getMeta('html.documentHeader', '').split('\n')),
          fragment(generateNodes(nodes))
        ])
      ]) 
    ].join('\n');
  }

  function generateHead(nodes:Array<Node>):HtmlChildren {
    var prefix = definition.getMeta('html.documentTitlePrefix');
    var css = definition.getMeta('html.documentStyles');
    var title = 'Boxup Document';

    for (node in nodes) switch node.type {
      case Block(name):
        var def = definition.getBlock(name);
        if (def != null) {
          var prop = def.getMeta('html.setDocumentTitle');
          if (prop != null) {
            title = node.getProperty(prop, 'Boxup Document');
            break;
          }
        }
      default:
    }

    if (prefix != null) title = '$prefix | $title';

    return () -> [
      el('title', [], () -> [ title ], { noIndent: true }),
      css != null
        ? el('link', [ 'rel' => 'stylesheet', 'href' => css ])
        : null
    ].filter(el -> el != null);
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
      case Block(BItalic):
        el('i', [], generateNodes(node.children), { noIndent: true });
      case Block(BRaw):
        el('code', [], generateNodes(node.children), { noIndent: true });
      case Block(name):
        var def = definition.getBlock(name);
        var hint = switch def {
          case null: 'Section';
          case def: def.getMeta('html.renderHint', 'Section');
        }
        switch hint {
          case 'None':
            null;
          case 'Template':
            var children = generateNodes(node.children, def.getMeta('html.wrapParagraph') != 'false');
            var template = new Template(def.getMeta('html.template', '::children::'));
            var context:DynamicAccess<String> = {};

            // Note: we remove indent here as the template should
            //       already have it
            removeIndent();
            for (prop in node.properties) 
              context.set(prop.name, prop.value.value);
            context.set('children', fragment(children));
            addIndent();
            
            fragment(() -> template.execute(context).split('\n'));

          case 'Header':
            el('h1', [ 'class' => generateClassName(name, node) ], generateNodes(node.children, false), { noIndent: true });
          case 'SubHeader':
            el('h2', [ 'class' => generateClassName(name, node) ], generateNodes(node.children, false), { noIndent: true });
          case 'ListContainer':
            el('ul', [ 'class' => generateClassName(name, node) ], generateNodes(node.children));
          case 'ListItem': 
            el('li', [ 'class' => generateClassName(name, node) ], generateNodes(node.children, false));
          case 'Link':
            el('a', [
              'href' => node.getProperty('href')
            ], generateNodes(node.children, false), { noIndent: true });
          case 'Image':
            el('img', [
              'src' => node.getProperty('src'),
              'alt' => node.getProperty('alt')
            ]);
          case 'Code':
            el('pre', [
              'class' => generateClassName(name, node)
            ], generateNodes([ node.children.extractText() ], false));
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
      case id: '${className} ${className}--${id.toLowerCase().htmlEscape().replace(' ', '-')}';
    }
  }

  function generateNodes(nodes:Array<Node>, wrapParagraph:Bool = true) {
    return () -> nodes.map(node -> generateNode(node, wrapParagraph)).filter(n -> n != null);
  }

  function fragment(children:HtmlChildren, ?alwaysIndent:Bool = false) {
    var parts = children();
    var result = [ for (index => child in parts) {
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
