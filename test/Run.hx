import boxup.cli.*;
import boxup.Node;
import boxup.Generator;
import boxup.Builtin;

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
  a {
    color: inherit;
  }
  a:hover {
    color: inherit;
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
    background: #f7f7f7;
    color: #8a8a8a;
    margin-bottom: 40px;
  }
  .page {
    padding-left: 10px;
    padding-top: 10px;
    border-top: 1px solid #e8e8e8;
    margin-bottom: 40px;
  }
  .page h2 {
    color: #cccccc;
  }
  .panel {
    margin-bottom: 40px;
  }
  .panel .attached:before {
    content: "(attached)";
    color: #8a8a8a;
  }
  .panel .mood {
    color: #8a8a8a;
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
      case Block(BBold):
        '<b>${generateNodes(node.children)}</b>';
      case Block(BItalic) | Block(BUnderlined):
        '<i>${generateNodes(node.children)}</i>';
      case Block(BRaw):
        '<pre>${generateNodes(node.children)}</pre>';
      case Block('Mood'):
        var out = '<i class="mood">${node.children.map(n -> switch n.type {
          case Paragraph: generateNodes(n.children);
          default: generateNode(n);
        }).join('')}</i>';
        if (node.isTag) out else '<p>${out}</p>';
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