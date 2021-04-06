package boxup.cli.generator;

import boxup.Builtin;

class GeneratorTools {
  public static function extractText(nodes:Array<Node>):Node {
    var content:Array<Node> = [];
    for (node in nodes) switch node.type {
      case Paragraph:
        content.push(extractText(node.children));
      case Block(BRaw):
        content.push({
          type: Text,
          textContent: extractText(node.children).textContent,
          children: [],
          properties: [],
          pos: node.pos
        });
      case Text:
        content.push(node);
      default:
        // skip??
    }

    return ({
      type: Text,
      textContent: content.map(n -> n.textContent).join('\n'),
      children: [],
      properties: [],
      pos: nodes[0].pos
    }:Node);
  }
}