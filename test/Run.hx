import boxup.cli.generator.HtmlGenerator;
import boxup.Outcome;
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

class ComicHtmlGenerator extends HtmlGenerator {
  var pageCount = 0;
  var panelCount = 0;

  override function generate(nodes:Array<Node>):Outcome<String> {
    pageCount = 0;
    panelCount = 0;
    return super.generate(nodes);
  }

  override function generateHead(nodes:Array<Node>):HtmlChildren {
    var comic = nodes.find(n -> switch n.type {
      case Block('Comic'): true;
      default: false;
    });
    return () -> [
      el('title', [], () -> [ if (comic != null) comic.getProperty('title') else 'Boxup Comic' ]),
      el('style', [], () -> [ '
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
      ' ])
    ];
  }

  override function generateNode(node:Node, wrapParagraph:Bool = true):String {
    return switch node.type {
      case Block('Comic'):
        el('header', [
          'class' => 'comic'
        ], () -> [
          el('h1', [], () -> [ node.getProperty('title') ], { noIndent: true }),
          el('span', [ 'class' => 'author' ], () -> [ node.getProperty('author') ], { noIndent: true })
        ]);
      case Block('Link'):
        el('a', [ 'href' => node.getProperty('url') ], generateNodes(node.children), { noIndent: true });
      case Block('Page'):
        pageCount++;
        panelCount = 0;
        el('div', [
          'class' => 'page',
          'id' => 'Page-${pageCount}-${panelCount}'
        ], generateNodes(node.children));
      case Block('Panel'):
        panelCount++;
        el('div', [
          'class' => 'panel'
        ], () -> [
          el('h3', [ 'class' => 'panel-label' ], () -> [ 'Panel ${pageCount}.${panelCount}' ]),
          fragment(generateNodes(node.children))
        ]);
      case Block('Dialog'):
        el('div', [
          'class' => 'dialog'
        ], () -> [
          el('h4', [ 'class' => 'dialog-character' ], () -> [ node.getProperty('character') ]),
          fragment(generateNodes(node.children))
        ]);
      case Block(BBold):
        el('b', [], generateNodes(node.children), { noIndent: true });
      case Block(BItalic) | Block(BUnderlined):
        el('i', [], generateNodes(node.children), { noIndent: true });
      case Block(BRaw):
        el('pre', [], generateNodes(node.children));
      case Block('Mood'):
        el('i', [
          'class' => 'mood'
        ], generateNodes(node.children, false));
      case Block(name):
        el('div', [ 'class' => name.toLowerCase() ], generateNodes(node.children));
      case Paragraph if (wrapParagraph):
        el('p', [], generateNodes(node.children, false), { noIndent: true });
      case Paragraph:
        fragment(generateNodes(node.children, false));
      case Text:
        StringTools.htmlEscape(node.textContent);
      case Arrow:
        '';
    }
  }
}
