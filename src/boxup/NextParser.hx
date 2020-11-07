package boxup;

import haxe.ds.Option;
import boxup.internal.Builtin;
import boxup.internal.AstParser;
import boxup.internal.Source;
import boxup.internal.Node;
import boxup.internal.ParserException;

using StringTools;
using Lambda;

typedef DefintionProperty = {
  public final name:String;
  public final type:String;
  public final isText:Bool;
  public final isOptional:Bool;
}

enum BlockDefinitionItem {
  BlockChild(name:String, ?alias:String);
  BlockDef(def:BlockDefinition);
}

@:structInit
class BlockDefinition {
  public static function fromNode(node:Node, parent:BlockDefinition):BlockDefinitionItem {
    switch node.pragma {
      case Some('child'):
        var alias = {
          var prop = node.properties.find(p -> p.name == 'as');
          if (prop == null) node.block.split('.').pop() else prop.value.value;
        }
        return BlockChild(node.block, alias);

      case Some('namespace'):
        var namespace:BlockDefinition = {
          name: node.block,
          isNamespace: true,
          properties: [],
          children: []
        };
        for (child in node.children) namespace.add(child);
        return BlockDef(namespace);

      case Some('block') | Some('paragraph'):
        var props = parseProperties(node);
        var name = node.block;
        var children = node.children.filter(node -> switch node.pragma {
          case Some('text') | Some('property'): false;
          default: true;
        });
        var isParagraph = node.pragma.equals(Some('paragraph'));
        var def:BlockDefinition = {
          name: name,
          parent: parent,
          properties: props,
          isParagraph: isParagraph,
          children: []
        };
        for (node in children) def.add(node);
        if (isParagraph) def.children.push(BlockDef({
          name: Builtin.text,
          isParagraph: false,
          parent: def,
          properties: [
            { 
              name: Builtin.textProperty, 
              type: 'String', 
              isText: true, 
              isOptional: false 
            }
          ],
          children: []
        }));
        return BlockDef(def);

      case Some(_) | None:
        throw new ParserException('Invalid toplevel definition', node.pos);
    }
  }

  static function parseProperties(parent:Node):Array<DefintionProperty> {
    var props = parent.children.filter(child -> switch child.pragma {
      case Some('text') | Some('property'):
        true;
      default: 
        false;
    });
    if (props.length == 0) return [];
    // todo: throw an error if we properties other than the allowed ones.
    return [ for (prop in props) {
      name: prop.block,
      type: switch prop.properties.find(n -> n.name == 'type') {
        case null: 'String';
        case t: switch t.value.value {
          case 'String' | 'Float' | 'Int': t.value.value;
          default:
            throw new ParserException(
              'Type may only be String, Float or Int for now',
              t.value.pos
            );
        }
      },
      isText: prop.pragma.equals(Some('text')),
      isOptional: switch prop.properties.find(n -> n.name == 'isOptional') {
        case null: false;
        case prop: switch prop.value.value {
          case 'true': true;
          case 'false': false;
          case _:
            throw new ParserException(
              'isOptional must be true or false',
              prop.pos
            );
        }
      }
    } ];
  }

  public final name:String;
  public final isNamespace:Bool = false;
  public final isParagraph:Bool = false;
  public final properties:Array<DefintionProperty>;
  public final children:Array<BlockDefinitionItem>;
  public final parent:BlockDefinition = null;

  public function handle(node:Node, parser:NextParser):Block {
    var props:Array<{ name:String, value:Dynamic }> = [];

    for (prop in node.properties) {
      var def = if (prop.name == Builtin.textProperty) {
        properties.find(def -> def.isText);
      } else {
        properties.find(def -> prop.name == def.name);
      }
      if (def == null) {
        throw new boxup.internal.ParserException(
          'Invalid property: ' + prop.name,
          prop.pos
        );
      }
      var value:Dynamic = switch def.type {
        case 'String': prop.value.value;
        case 'Int': try {
          Std.parseInt(prop.value.value);
        } catch (e) {
          throw new ParserException(
            'Expected an int',
            prop.value.pos
          );
        }
        case 'Float': try 
          Std.parseFloat(prop.value.value)
        catch (e) 
          throw new ParserException(
            'Expected a float',
            prop.value.pos
          );
        case _: prop.value.value;
      }
      props.push({
        name: def.name,
        value: value
      });
    }

    return {
      name: name,
      properties: props,
      children: parser.parseNodes(node.children, this)
    };
  }

  public function add(node:Node) {
    children.push(fromNode(node, this));
  }

  public function get(name:String):BlockDefinition {
    for (child in children) switch child {
      case BlockChild(blkName, alias) if (parent != null):
        if (alias == name) {
          return get(blkName);
        }
        if (blkName == name) {
          var def = parent.get(name);
          if (def != null) return def;
        }
      case BlockDef(def):
        if (def.name == name) return def;
        if (def.isNamespace && name.contains('.')) {
          var parts = name.split('.');
          var ns = parts.shift();
          if (ns == def.name) {
            return def.get(parts.join('.'));
          }
        }
      default: 
        null;
    }
    return null;
  }

  public function getParagraph():BlockDefinition {
    for (child in children) switch child {
      case BlockChild(name, _) if (parent != null):
        var def = parent.get(name);
        if (def.isParagraph) return def;
      case BlockDef(def):
        if (def.isParagraph) return def;
      default: 
        null;
    }
    return null;
  }
}

@:structInit
class Block {
  public final name:String;
  public final properties:Array<{ name:String, value:Dynamic }>;
  public final children:Array<Block>;
}

typedef Document = {
  public final definitions:Array<BlockDefinition>;
  public final blocks:Array<Block>;
}

// This API is a disaster.
class NextParser {
  public static function parseDefinitions(source:Source) {
    var nodes = new AstParser(source).parse();
    var root:BlockDefinition = {
      name: '@root',
      isParagraph: false,
      properties: [],
      children: []
    };
    for (node in nodes) switch node.pragma {
      case Some(_): root.add(node);
      case None:
    }
    return root;
  }

  final root:BlockDefinition;

  public function new(?root) {
    this.root = if (root == null) {
      name: '@root',
      isParagraph: false,
      properties: [],
      children: []
    } else root;
  }

  public function parse(source:Source) {
    var nodes = new AstParser(source).parse();
    return parseNodes(nodes, root);
  }
        
  public function parseNodes(nodes:Array<Node>, definition:BlockDefinition):Array<Block> {
    var blocks:Array<Block> = [];
    for (node in nodes) switch parseNode(node, definition) {
      case None:
      case Some(block): blocks.push(block);
    }
    return blocks;
  }

  function parseNode(node:Node, definition:BlockDefinition):Option<Block> {
    switch node.pragma {
      case Some(_):
        root.add(node);
        return None;
      case None:
        var def = switch node.block {
          case Builtin.paragraph: definition.getParagraph();
          default: definition.get(node.block);
        }
        if (def == null) {
          throw new ParserException(
            'Invalid block: the block [' + node.block + '] is not allowed here or was not defined.',
            node.pos
          );
        }
        return Some(def.handle(node, this));
    }
  }
}
