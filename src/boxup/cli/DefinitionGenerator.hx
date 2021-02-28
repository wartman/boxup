package boxup.cli;

import boxup.Generator;
import boxup.cli.Definition;
import boxup.Builtin;

using Lambda;

class DefinitionGenerator implements Generator<Definition> {
  static final defaultParagraphChildren:Array<ChildDefinition> = [
    { name: BItalic },
    { name: BBold },
    { name: BUnderlined },
    { name: BRaw }
  ];

  static final defaultBlocks:Array<BlockDefinition> = [
    {
      name: BItalic,
      kind: BTag,
      children: [],
      properties: []
    },
    {
      name: BBold,
      kind: BTag,
      children: [],
      properties: []
    },
    {
      name: BUnderlined,
      kind: BTag,
      children: [],
      properties: []
    },
    {
      name: BRaw,
      kind: BTag,
      children: [],
      properties: []
    }
  ];

  public function new() {}

  public function generate(nodes:Array<Node>):Outcome<Definition> {
    var blocks:Array<BlockDefinition> = [].concat(defaultBlocks);

    for (node in nodes) {
      switch node.type {
        case Block('Root'):
          blocks.push({
            name: BRoot,
            children: generateChildren(node),
            properties: []
          });
        case Block('Block'):
          var kind = node.getProperty('kind', BlockDefinitionKind.BNormal);
          blocks.push({
            name: node.getProperty('name'),
            kind: kind,
            children: switch kind {
              case BParagraph:
                defaultParagraphChildren.concat(generateChildren(node));
              default: generateChildren(node);
            },
            properties: generateProperties(node)
          });
        default:
          // Noop
      }
    }

    return Ok(new Definition(blocks));
  }

  inline function generateProperties(node:Node) {
    return node.children.filter(n -> switch n.type {
      case Block('Property') | Block('EnumProperty'): true;
      default: false;
    }).map(n -> ({
      name: n.getProperty('name'),
      required: n.getProperty('required') == 'true',
      type: n.getProperty('type') != null ? n.getProperty('type') : 'String',
      allowedValues: switch n.type {
        case Block('EnumProperty'): n.children.filter(n -> switch n.type {
          case Block('Option'): true;
          default: false;
        }).map(n -> n.getProperty('value'));
        default: [];
      }
    }:PropertyDefinition));
  }

  inline function generateChildren(node:Node) {
    return node.children.filter(n -> switch n.type {
      case Block('Child'): true;
      default: false;
    }).map(n -> ({
      name: n.getProperty('name'),
      required: n.getProperty('required', 'false') == 'true',
      multiple: n.getProperty('multiple', 'true') == 'true'
    }:ChildDefinition));
  }
}
