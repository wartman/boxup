package boxup;

import boxup.internal.AstParser;
import boxup.internal.Source;
import boxup.internal.Node;
import boxup.internal.ParserException;

using Lambda;

typedef DefintionProperty = {
  public final name:String;
  public final type:String;
  public final isOptional:Bool;
}

@:structInit
class BlockDefinition {
  public static function fromNode(node:Node) {
    switch node.pragma {
      // case 'document': // todo
      case Some('block'):
        var name = node.block;
        var props = parseProperties(node);
      case Some(_) | None:
        throw new ParserException('Invalid toplevel definition', node.pos);
    }
  }

  static function parseProperties(parent:Node):Array<DefintionProperty> {
    var props = parent.children.filter(child -> switch child.pragma {
      case Some('property'): true;
      default: false;
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
  public final properties:Array<DefintionProperty>;
  public final children:Array<BlockDefinition>;

  public function handle(node:Node, parser:NextParser):Block {
    var props:Array<{ name:String, value:Dynamic }> = [];

    for (prop in node.properties) {
      var def = properties.find(def -> prop.name == def.name);
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
        name: prop.name,
        value: value
      });
    }

    return {
      name: node.block,
      properties: props,
      children: parser.parseNodes(node.children, children)
    };
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

class NextParser {
  var definitions:Array<BlockDefinition>;

  public function new(?definitions) {
    this.definitions = if (definitions == null) [] else definitions;
  }

  public function parse(source:Source):Document {
    var nodes = new AstParser(source).parse();
    var children = parseNodes(nodes, definitions);
    return {
      definitions: definitions,
      blocks: children
    };
  }

  public function parseNodes(nodes:Array<Node>, definitions:Array<BlockDefinition>):Array<Block> {
     return [ for (node in nodes) parseNode(node, definitions) ];
  }

  public function extractDefinitions(nodes:Array<Node>) {
    var defs = nodes.filter(node -> !node.pragma.equals(None));

  }

  function parseNode(node:Node, definitions:Array<BlockDefinition>):Block {
    var def = definitions.find(def -> node.block == def.name);
    if (def == null) {
      throw new ParserException(
        'Invalid block: the block [' + node.block + '] is not allowed here.',
        node.pos
      );
    }
    return def.handle(node, this);
  }
}
