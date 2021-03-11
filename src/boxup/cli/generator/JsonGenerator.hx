package boxup.cli.generator;

import haxe.Json;
import haxe.DynamicAccess;

class JsonGenerator implements Generator<String> {
  public function new() {}

  public function generate(nodes:Array<Node>):Outcome<String> {
    return Ok(Json.stringify(nodes.map(generateNode), '    '));
  }

  function generateNode(node:Node):Dynamic {
    return switch node.type {
      case Block(name):
        {
          type: 'Block',
          name: name,
          properties: generateProperties(node),
          children: node.children.map(generateNode)
        };
      case Paragraph:
        {
          type: 'Paragraph',
          children: node.children.map(generateNode)
        };
      case Text:
        {
          type: 'Text',
          content: node.textContent
        };
    }
  }

  function generateProperties(node:Node){
    var props:DynamicAccess<Dynamic> = {};
    for (prop in node.properties) {
      props.set(prop.name, switch prop.value.type {
        case 'String': prop.value.value;
        case 'Int': Std.parseInt(prop.value.value);
        case 'Bool': prop.value.value == 'true';
        default: prop.value.value;
      });
    }
    return props;
  }
}
