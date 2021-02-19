package boxup.cli;

import boxup.Generator;
import boxup.cli.Definition;

using Lambda;

class DefinitionGenerator implements Generator<Definition> {
  public function new() {}

  public function generate(nodes:Array<Node>):Definition {
    var blocks:Array<BlockDefinition> = [];

    for (node in nodes) {
      switch node.type {
        case Block('Root'):
          blocks.push({
            name: '@root',
            isTag: false,
            isParagraph: false,
            required: false,
            children: generateChildren(node),
            properties: []
          });
        case Block('Block'):
          blocks.push({
            name: node.getProperty('name'),
            isTag: node.getProperty('isTag', 'false') == 'true',
            isParagraph: false,
            required: node.getProperty('required', 'false') == 'true',
            children: generateChildren(node),
            properties: generateProperties(node)
          });
        case Block('Paragraph'):
          blocks.push({
            name: node.getProperty('name'),
            isParagraph: true,
            isTag: false,
            required: false,
            children: generateChildren(node),
            properties: generateProperties(node)
          });
        default:
          // Noop
      }
    }

    return new Definition(blocks);
  }

  inline function generateProperties(node:Node) {
    return node.children.filter(n -> switch n.type {
      case Block('Property'): true;
      default: false;
    }).map(n -> ({
      name: n.getProperty('name'),
      required: n.getProperty('required') == 'true',
      type: n.getProperty('type') != null ? n.getProperty('type') : 'String',
      defaultValue: n.getProperty('default')
    }:PropertyDefinition));
  }

  inline function generateChildren(node:Node) {
    return node.children.filter(n -> switch n.type {
      case Block('Child'): true;
      default: false;
    }).map(n -> ({
      name: n.getProperty('name'),
      required: n.getProperty('requried', 'false') == 'true',
      multiple: n.getProperty('multiple', 'true') == 'true'
    }:ChildDefinition));
  }
}
