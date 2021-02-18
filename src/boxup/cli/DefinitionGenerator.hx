package boxup.cli;

import boxup.Generator;
import boxup.cli.Definition;

using Lambda;

class DefinitionGenerator implements Generator<Definition> {
  public function new() {}

  public function generate(nodes:Array<Node>):Definition {
    var blocks:Array<BlockDefinition> = [];

    for (node in nodes) {
      inline function properties() {
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

      inline function children() {
        return node.children.filter(n -> switch n.type {
          case Block('Child'): true;
          default: false;
        }).map(n -> n.getProperty('name'));
      }

      switch node.type {
        case Block('Block'):
          blocks.push({
            name: node.getProperty('name'),
            isTag: node.getProperty('isTag', 'false') == 'true',
            isRoot: node.getProperty('isRoot', 'false') == 'true',
            isParagraph: false,
            required: node.getProperty('required', 'false') == 'true',
            children: children(),
            properties: properties()
          });
        case Block('Paragraph'):
          blocks.push({
            name: node.getProperty('name'),
            isParagraph: true,
            isTag: false,
            isRoot: node.getProperty('isRoot', 'false') == 'true',
            required: false,
            children: children(),
            properties: properties()
          });
        case Block(name):
        default:
          // Noop
      }
    }

    return new Definition(blocks);
  }
}
