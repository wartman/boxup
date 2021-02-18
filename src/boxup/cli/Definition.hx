package boxup.cli;

import haxe.Exception;
import boxup.Node;
import boxup.Validator;

using Lambda;

class Definition implements Validator {
  public static function generate(nodes:Array<Node>) {
    var blocks:Array<BlockDefinition> = [];

    for (node in nodes) {
      inline function prop(node:Node, name, def = null) {
        var prop = node.properties.find(p -> p.name == name);
        return prop == null ? def : prop.value.value;
      }

      inline function properties() {
        return node.children.filter(n -> switch n.type {
          case Block('Property'): true;
          default: false;
        }).map(n -> ({
          name: prop(n, 'name'),
          required: prop(n, 'required') == 'true',
          type: prop(n, 'type') != null ? prop(n, 'type') : 'String',
          defaultValue: prop(n, 'default')
        }:PropertyDefinition));
      }

      inline function children() {
        return node.children.filter(n -> switch n.type {
          case Block('Child'): true;
          default: false;
        }).map(n -> prop(n, 'name'));
      }

      switch node.type {
        case Block('Block'):
          blocks.push({
            name: prop(node, 'name'),
            isTag: prop(node, 'isTag', 'false') == 'true',
            isRoot: prop(node, 'isRoot', 'false') == 'true',
            isParagraph: false,
            required: prop(node, 'required', 'false') == 'true',
            children: children(),
            properties: properties()
          });
        case Block('Paragraph'):
          blocks.push({
            name: 'Paragraph',
            isParagraph: true,
            isTag: false,
            isRoot: prop(node, 'allowInRoot', 'false') == 'true',
            required: false,
            children: children(),
            properties: properties()
          });
        case Block(name):
        default:
          // Noop
      }
    }

    return new Definition(blocks, {
      name: 'ROOT',
      isTag: false,
      isRoot: true,
      isParagraph: false,
      required: true,
      children: blocks.filter(b -> b.isRoot).map(b -> b.name),
      properties: []
    });
  }

  final blocks:Array<BlockDefinition>;
  final root:BlockDefinition;

  public function new(blocks, root) {
    this.blocks = blocks;
    this.root = root;
  }

  public function getBlock(name:String) {
    return blocks.find(b -> b.name == name);
  }

  public function validate(nodes:Array<Node>):ValidationResult {
    var first = nodes[0];
    var last = nodes[nodes.length - 1];

    return root.validate({
      type: Block('ROOT'),
      textContent: null,
      properties: [],
      children: nodes,
      pos: {
        min: first.pos.min,
        max: last.pos.max,
        file: first.pos.file
      }
    }, this);
  }
}

@:structInit
class BlockDefinition {
  public final name:String;
  public final isRoot:Bool;
  public final isTag:Bool;
  public final isParagraph:Bool;
  public final required:Bool;
  public final children:Array<String>;
  public final properties:Array<PropertyDefinition>;

  public function validate(node:Node, definition:Definition):ValidationResult {
    var errors:Array<Error> = [];

    try validateProps(node) catch (e:Error) errors.push(e);

    function validateChild(name:String, child:Node) {
      if (!children.contains(name)) {
        errors.push(new Error('Invalid child for ${this.name}: ${name}', child.pos));
      }
      var block = definition.getBlock(name);
      if (block == null) {
        errors.push(new Error('Invalid block type: ${name}', node.pos));
      } else {
        var result = block.validate(child, definition);
        if (result.hasErrors) errors = errors.concat(result.errors);
      }
    }

    for (child in node.children) switch child.type {
      case Block(name): validateChild(name, child);
      case Paragraph: validateChild('Paragraph', child);
      case Text if (!isTag && !isParagraph):
        errors.push(new Error('Invalid child', child.pos));
      case Text:
        // ?
    }

    return {
      hasErrors: errors.length > 0,
      errors: errors
    }
  }
  function validateProps(node:Node) {
    var found:Array<String> = [];

    function checkForDuplicates(prop:Property) {
      if (found.contains(prop.name)) {
        throw new Error('Duplicate property', prop.pos);
      }
      found.push(prop.name);
    }

    for (prop in node.properties) {
      checkForDuplicates(prop);
      var def = properties.find(p -> p.name == prop.name);
      if (def == null) {
        throw new Error('Invalid property: ${prop.name}', prop.pos);
      }
      if (prop.value.type != def.type) {
        throw new Error('Should be a ${def.type} but was a ${prop.value.type}', prop.value.pos);
      }
    }

    for (def in properties) {
      if (def.required && !found.contains(def.name)) {
        throw new Error('Requires property ${def.name}', node.pos);
      }
    }
  }
}

@:structInit
class PropertyDefinition {
  public final name:String;
  public final required:Bool;
  public final type:String;
  public final defaultValue:Null<String>;

  public function validate(prop:Property):ValidationResult {
    return null;
  }
}
