import boxup.cli.*;
import boxup.Node;
import boxup.Generator;

using Lambda;

class Run {
  static function main() {
    App.runUsingEnv(
      new ComicHtmlGenerator(),
      new FileLoader(Sys.getCwd()),
      new FileWriter(Sys.getCwd()),
      new DefaultReporter()
    );
  }
}

class ComicHtmlGenerator implements Generator<String> {
  var pageCount = 0;
  var panelCount = 0;

  public function new() {}

  public function generate(nodes:Array<Node>):String {
    return '
<!doctype HTML>

<html>
<body>
<style>
  html {
    font-family: "Courier New", Courier;
    font-size: 15px;
    padding: 20px 10px;
  }
  body {
    max-width: 700px;
    margin: 0 auto;
  }
  h1, h2, h3, h4 {
    font-size: inherit;
    font-weight: normal;
    margin: 10px 0;
    text-transform: uppercase;
  }
  .comic {
    margin-bottom: 20px;
  }
  .notes {
    font-style: italic;
    padding: 5px 20px;
    background: #ccc;
  }
  .page {
    border-left: 5px solid #cccccc;
    padding-left: 10px;
    margin-bottom: 20px;
  }
  .page h2 {
    color: #cccccc;
  }
  .panel {

  }
  .dialog {
    text-align: center;
    margin-bottom: 20px;
  }
</style>
${generateNodes(nodes)}
</body>
</html>';
  }

  function generateNodes(nodes:Array<Node>) {
    return nodes.map(generateNode).join('');
  }

  function generateNode(node:Node) {
    return switch node.type {
      case Block('Comic'):
        '<header class="comic">
          <h1>${node.getProperty('title')}</h1>
          <span class="author">${node.getProperty('author')}</span>
        </header>';
      case Block('Link'):
        '<a href="${node.getProperty('url')}"">${generateNodes(node.children)}</a>';
      case Block('Page'):
        pageCount++;
        panelCount = 0;
        return '<div class="page">
          <h2>Page ${pageCount}</h2>
          ${generateNodes(node.children)}
        </div>';
      case Block('Panel'):
        panelCount++;
        return '<div class="panel">
          <h3>Panel ${panelCount}</h3>
          ${generateNodes(node.children)}
        </div>';
      case Block('Dialog'):
        '<div class="dialog">
          <h4 class="dialog-character">${node.getProperty('character')}</h4>
          ${generateNodes(node.children)}
        </div>';
      case Block('Emphasis'):
        '<b>${generateNodes(node.children)}</b>';
      case Block(name): nodeToHtml(name, node);
      case Paragraph: 
        '<p>${generateNodes(node.children)}</p>';
      case Text: 
        node.textContent;
      default: '';
    }
  }

  function nodeToHtml(name:String, node:Node) {
    var props = [ for (p in node.properties) 
      '${p.name}="${p.value.value}"'
    ];
    props.push('class="${name.toLowerCase()}"');
    var out = '<div ${props.join(' ')}';
    return if (node.children.length > 0)
      out + '>' + node.children.map(generateNode).join('') + '</div>'
    else
      out + '/>';
  }
}