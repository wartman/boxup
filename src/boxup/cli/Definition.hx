package boxup.cli;

import boxup.Node;
import boxup.Validator;
import boxup.Builtin;

using Lambda;

class Definition implements Validator {
  final blocks:Array<BlockDefinition>;

  public function new(blocks) {
    this.blocks = blocks;
  }

  public function getBlock(name:String) {
    return blocks.find(b -> b.name == name);
  }

  public function validate(nodes:Array<Node>):ValidationResult {
    var first = nodes[0];

    return getBlock(BRoot).validate({
      type: Block(BRoot),
      textContent: null,
      properties: [],
      children: nodes,
      pos: {
        min: 0,
        max: 0,
        file: first.pos.file
      }
    }, this);
  }
}

enum abstract BlockDefinitionKind(String) from String to String {
  var BNormal = 'Normal';
  var BTag = 'Tag';
  var BArrow = 'Arrow';
  var BParagraph = 'Paragraph';
}

@:structInit
class BlockDefinition {
  public final name:String;
  public final kind:BlockDefinitionKind = BNormal;
  public final children:Array<ChildDefinition>;
  public final properties:Array<PropertyDefinition>;

  public var isParagraph(get, never):Bool;
  function get_isParagraph() return kind == BParagraph;

  public var isTag(get, never):Bool;
  function get_isTag() return kind == BTag;

  public var isArrow(get, never):Bool;
  function get_isArrow() return kind == BArrow;

  public function validate(node:Node, definition:Definition):ValidationResult {
    var errors:Array<Error> = [];
    var existingChildren:Array<String> = [];

    switch kind {
      case BNormal | BTag | BArrow:
        try validateProps(node) catch (e:Error) errors.push(e);
      case BParagraph if (node.properties.length > 0):
        errors.push(new Error('Properties are not allowed in paragraph blocks', node.properties[0].pos));
      default:
    }

    function validateChild(name:String, child:Node) {
      if (!children.exists(c -> c.name == name)) {
        errors.push(new Error('The block ${name} is an invalid child for ${this.name}', child.pos));
      }
      var childDef = children.find(c -> c.name == name);
      var block = definition.getBlock(name);
      if (block == null) {
        errors.push(new Error('Unknown block type: ${name}', child.pos));
      } else if (existingChildren.contains(name) && childDef.multiple == false) {
        errors.push(new Error('Only one ${name} block is allowed for ${this.name}', child.pos));
      } else {
        existingChildren.push(name);
        switch block.validate(child, definition) {
          case Failed(e): 
            errors = errors.concat(e);
          case Passed:
        }
      }
    }

    for (child in node.children) switch child.type {
      case Block(name): 
        validateChild(name, child);
      case Arrow:
        var arrow:BlockDefinition = null;
        for (child in children) {
          var b = definition.getBlock(child.name);
          if (b.isArrow) arrow = b;
        }
        if (arrow == null) {
          errors.push(new Error('No Arrow Blocks are allowed here', child.pos));
        } else {
          validateChild(arrow.name, child);
        }
      case Paragraph: 
        var para:BlockDefinition = null;
        for (child in children) {
          var b = definition.getBlock(child.name);
          if (b.isParagraph) para = b;
        }
        if (para == null) {
          errors.push(new Error('No Paragraphs are allowed here', child.pos));
        } else {
          validateChild(para.name, child);
        }
      case Text if (!isTag && !isParagraph):
        errors.push(new Error('Invalid child', child.pos));
      case Text:
        // ?
    }

    for (child in children) {
      if (child.required && !existingChildren.contains(child.name)) {
        errors.push(new Error('Requires a ${child.name} block', node.pos));
      }
    }

    return errors.length > 0 ? Failed(errors) : Passed;
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
      if (
        def.allowedValues.length > 0
        && !def.allowedValues.contains(prop.value.value)  
      ) {
        throw new Error('Value must be one of: ${def.allowedValues.join(', ')}', prop.value.pos);
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
class ChildDefinition {
  public final name:String;
  public final required:Bool = false;
  public final multiple:Bool = true;
}

@:structInit
class PropertyDefinition {
  public final name:String;
  public final required:Bool = false;
  public final type:String = 'String';
  public final allowedValues:Array<String> = [];
}
