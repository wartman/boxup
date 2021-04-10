package boxup.cli.generator;

import haxe.DynamicAccess;
import haxe.Template;
import boxup.Builtin;

using boxup.cli.generator.GeneratorTools;

class MarkdownGenerator implements Generator<String> {
  final definition:Definition;

  public function new(definition) {
    this.definition = definition;
  }

  public function generate(nodes:Array<Node>, source:Source):Result<String> {
    return Ok(fragment(nodes));
  }

  function generateNodes(nodes:Array<Node>) {
    return nodes.map(generateNode);
  }

  function generateNode(node:Node) {
    return switch node.type {
      case Paragraph:
        fragment(node.children, true) + '\n';
      case Text:
        node.textContent;
      case Block(BBold):
        '**' + fragment(node.children) + '**';
      case Block(BItalic):
        '_' + fragment(node.children) + '_';
      case Block(BRaw):
        '`' + fragment(node.children) + '`';
      case Block(name):
        var def = definition.getBlock(name);
        var hint = switch def {
          case null: 'Fragment';
          case def: def.getMeta('md.renderHint', 'Fragment');
        }

        switch hint {
          case 'Template':
            var template = new Template(def.getMeta('md.template', '::children::'));
            var context:DynamicAccess<String> = {};

            for (prop in node.properties) 
              context.set(prop.name, prop.value.value);
            context.set('children', fragment(node.children));

            template.execute(context);

          case 'Header':
            '# ' + fragment(node.children);

          case 'SubHeader':
            '## ' + fragment(node.children);

          case 'ListContainer':
            '\n' + fragment(node.children);

          case 'ListItem':
            '- ' + fragment(node.children);

          case 'Link':
            '[${fragment(node.children)}](${node.getProperty('href')})';

          case 'Code':
            '```${node.id.value}\n${fragment([node.children.extractText()])}\n```\n';
            
          default: fragment(node.children);
        }
    }
  }

  function fragment(nodes:Array<Node>, isInline:Bool = false) {
    return generateNodes(nodes).join(isInline ? '' : '\n');
  }
}