package boxup.generator;

import boxup.stream.Accumulator;
import haxe.DynamicAccess;
import haxe.Template;
import boxup.Builtin;
import boxup.stream.ReadStream;
import boxup.definition.Definition;

using boxup.generator.GeneratorTools;

class MarkdownGenerator extends Generator<String> {
  final definition:Definition;

  public function new(definition) {
    this.definition = definition;
    super();
  }

  public function generate(nodes:Array<Node>) {
    fragment(nodes);
    output.end();
  }

  function generateNodes(nodes:Array<Node>) {
    for (node in nodes) generateNode(node);
  }

  inline function add(str:String) {
    output.push(str);
  }

  function generateNode(node:Node) {
    switch node.type {
      case Paragraph:
        fragment(node.children, true);
        add('\n');
      case Text:
        node.textContent;
      case Block(BBold):
        add('**');
        fragment(node.children); 
        add('**');
      case Block(BItalic):
        add('_');
        fragment(node.children);
        add('_');
      case Block(BRaw):
        add('`');
        fragment(node.children);
        add('`');
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

            if (node.children != null && node.children.length > 0) {
              var generator = new MarkdownGenerator(definition);
              var accumulator = new Accumulator(parts -> {
                context.set('children', parts.join(''));
              });
              generator.pipe(accumulator);
              generator.write(node.children);
            }

            add(template.execute(context));

          case 'Header':
            add('# ');
            fragment(node.children);

          case 'SubHeader':
            add('## ');
            fragment(node.children);

          case 'ListContainer':
            add('\n');
            fragment(node.children);

          case 'ListItem':
            add('- ');
            fragment(node.children);

          case 'Link':
            add('[');
            fragment(node.children);
            add('](${node.getProperty('href')})');

          case 'Code':
            add('```${node.id.value}\n');
            fragment([node.children.extractText()]);
            add('\n```\n');
            
          default: 
            fragment(node.children);
        }
    }
  }

  function fragment(nodes:Array<Node>, isInline:Bool = false):Void {
    for (node in nodes) {
      generateNode(node);
      if (!isInline) add('\n');
    }
  }
}