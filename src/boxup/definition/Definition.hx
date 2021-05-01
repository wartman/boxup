package boxup.definition;

import boxup.Builtin;

using Lambda;

class Definition implements Validator {
  public final id:DefinitionId;
  final blocks:Array<BlockDefinition>;
  final meta:Map<String, String>;

  public function new(id, blocks, meta) {
    this.id = id;
    this.blocks = blocks;
    this.meta = meta;
  }

  public function getBlock(name:String) {
    return blocks.find(b -> b.name == name);
  }

  public function getMeta(name:String, ?def:String) {
    return meta.exists(name) ? meta.get(name) : def;
  }

  public function validate(nodes:Array<Node>, source:Source):Result<Array<Node>> {
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
    }, this).map(_ -> Ok(nodes));
  }
}

enum abstract BlockDefinitionKind(String) from String to String {
  var BNormal = 'Normal';
  var BTag = 'Tag';
  var BParagraph = 'Paragraph';
  var BPropertyBag = 'PropertyBag';
}

@:structInit
class BlockDefinition {
  public final name:String;
  public final meta:Map<String, String> = [];
  public final kind:BlockDefinitionKind = BNormal;
  public final children:Array<ChildDefinition>;
  public final properties:Array<PropertyDefinition>;

  public var isParagraph(get, never):Bool;
  function get_isParagraph() return kind == BParagraph;

  public var isTag(get, never):Bool;
  function get_isTag() return kind == BTag;

  public function getIdProperty():Null<String> {
    var prop = properties.find(p -> p.isId);
    return if (prop != null) prop.name else null;
  }

  public function getMeta(name:String, ?def:String) {
    return meta.exists(name) ? meta.get(name) : def;
  }

  public function validate(node:Node, definition:Definition):Result<Node> {
    var errors = ErrorCollection.empty();
    var existingChildren:Array<String> = [];

    switch kind {
      case BNormal | BTag | BPropertyBag:
        validateProps(node).handleError(errors.addAll);
      case BParagraph if (node.properties.length > 0):
        errors.add(new Error('Properties are not allowed in paragraph blocks', node.properties[0].pos));
      default:
    }

    function validateChild(name:String, child:Node) {
      if (children.exists(c -> c.symbol == name)) {
        var def = children.find(c -> c.symbol == name);
        name = def.name;
        child.type = Block(def.name);
      }
      if (!children.exists(c -> c.name == name)) {
        errors.add(new Error('The block ${name} is an invalid child for ${this.name}', child.pos));
      }
      var childDef = children.find(c -> c.name == name);
      var block = definition.getBlock(name);
      
      if (childDef == null) {
        errors.add(new Error('Child not allowed: ${name}', child.pos));
      } else if (block == null) {
        errors.add(new Error('Unknown block type: ${name}', child.pos));
      } else if (existingChildren.contains(name) && childDef.multiple == false) {
        errors.add(new Error('Only one ${name} block is allowed for ${this.name}', child.pos));
      } else {
        existingChildren.push(name);
        block
          .validate(child, definition)
          .handleError(errors.addAll);
      }
    }

    for (child in node.children) switch child.type {
      case Block(name): 
        validateChild(name, child);
      case Paragraph: 
        var para:BlockDefinition = null;
        for (child in children) {
          var b = definition.getBlock(child.name);
          if (b.isParagraph) para = b;
        }
        if (para == null) {
          errors.add(new Error('No Paragraphs are allowed here', child.pos));
        } else {
          validateChild(para.name, child);
        }
      case Text if (!isTag && !isParagraph):
        errors.add(new Error('Invalid child', child.pos));
      case Text:
        // ?
    }

    for (child in children) {
      if (child.required && !existingChildren.contains(child.name)) {
        errors.add(new Error('Requires a ${child.name} block', node.pos));
      }
    }

    return errors.hasErrors() ? Fail(errors) : Ok(node);
  }

  function validateProps(node:Node):Result<Dynamic> {
    var found:Array<String> = [];

    switch getIdProperty() {
      case null:
        if (node.id != null) {
          return Fail(new Error('Unexpected id', node.id.pos));
        }
      case name:
        if (!node.properties.exists(n -> n.name == name) && node.id != null) {
          node.properties.push({
            name: name,
            value: node.id,
            pos: node.id.pos
          });
        }
    }

    for (prop in node.properties) {
      var def = properties.find(p -> p.name == prop.name);
      
      if (def == null) {
        if (kind == BPropertyBag) continue;
        return Fail(new Error('Invalid property: ${prop.name}', prop.pos));
      }

      if (found.contains(prop.name)) {
        return Fail(new Error('Duplicate property', prop.pos));
      }
      
      found.push(prop.name);
      
      if (prop.value.type != def.type) {
        return Fail(new Error('Should be a ${def.type} but was a ${prop.value.type}', prop.value.pos));
      }
      
      if (
        def.allowedValues.length > 0
        && !def.allowedValues.contains(prop.value.value)  
      ) {
        return Fail(new Error('Value must be one of: ${def.allowedValues.join(', ')}', prop.value.pos));
      }
    }

    for (def in properties) {
      if (def.required && !found.contains(def.name)) {
        return Fail(new Error('Requires property ${def.name}', node.pos));
      }
    }

    return Ok();
  }
}

@:structInit
class ChildDefinition {
  public final name:String;
  public final symbol:Null<String> = null;
  public final required:Bool = false;
  public final multiple:Bool = true;
}

@:structInit
class PropertyDefinition {
  public final name:String;
  public final isId:Bool = false;
  public final required:Bool = false;
  public final type:String = 'String';
  public final allowedValues:Array<String> = [];
}
