package boxup.generator;

import boxup.stream.Accumulator;
import haxe.DynamicAccess;
import haxe.Template;
import boxup.Builtin;
import boxup.definition.Definition;

using boxup.generator.GeneratorTools;
using StringTools;

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
        fragment(node.children);
        breakSection();
      case Text:
        add(node.textContent);
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
                context.set('children', parts.join('').trim());
              });
              generator.pipe(accumulator);
              generator.write(node.children);
            }

            add(template.execute(context));
            breakSection();

          case 'Header':
            add('# ');
            fragment(node.children);
            breakSection();

          case 'SubHeader':
            add('## ');
            fragment(node.children);
            breakSection();

          case 'ListContainer':
            fragment(node.children);
            breakSection();

          case 'ListItem':
            add('- ');
            fragment(node.children);
            breakSection();

          case 'Link':
            add('[');
            fragment(node.children);
            add('](${node.getProperty('href')})');

          case 'Code':
            add('```${node.id.value}\n');
            fragment([node.children.extractText()]);
            add('\n```\n\n');
            
          default: 
            fragment(node.children);
        }
    }
  }

  function breakSection() {
    add('\n\n');
  }

  function fragment(nodes:Array<Node>):Void {
    for (node in nodes) generateNode(node);
  }
}