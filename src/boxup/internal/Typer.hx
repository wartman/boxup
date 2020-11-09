package boxup.internal;

import haxe.ds.Option;

using StringTools;
using Lambda;

// This still feels clumsy and weird, but we're getting a bit closer.
class Typer {
  public static function extractTypes(nodes:Array<Node>):Map<String, BlockType> {
    var types:Map<String, BlockType> = [
      Builtin.text => {
        name: Builtin.text,
        isRoot: false,
        isParagraph: false,
        properties: [
          {
            name: Builtin.textProperty,
            type: 'String',
            isText: true,
            isOptional: false
          }
        ],
        children: []
      }
    ];

    function join(parentName:Null<String>, name:String) {
      return parentName != null ? '${parentName}.${name}' : name;
    }

    function handle(nodes:Array<Node>, ?parentName:String):Array<BlockTypeName> {
      var paths:Array<BlockTypeName> = [];
      for (node in nodes) switch node.pragma {
        case Some('child'):
          var alias = {
            var prop = node.properties.find(p -> p.name == 'as');
            if (prop == null) 
              if (node.block.startsWith('@')) 
                node.block  
              else
                node.block.split('.').pop() 
            else 
              prop.value.value;
          }
          paths.push({ alias: alias, fullPath: node.block });
        case Some('namespace'):
          paths = paths.concat(handle(node.children, join(parentName, node.block)));
        case Some('block') | Some('paragraph'):
          var name = node.block;
          var path = join(parentName, name);
          var props = extractProperties(node);
          var isParagraph = node.pragma.equals(Some('paragraph')) || node.block == Builtin.paragraph;
          var children = handle(node.children.filter(n -> switch n.pragma {
            case Some('property') | Some('text'): false;
            default: true;
          }), path);
          if (isParagraph) children.push({
            fullPath: Builtin.text,
            alias: Builtin.text
          });
          var type:BlockType = {
            name: name,
            properties: props,
            children: children,
            isRoot: parentName == null,
            isParagraph: isParagraph
          };
          types.set(path, type);
          paths.push({ alias: name, fullPath: path });
        case Some(_) | None:
          throw new ParserException('Invalid pragma', node.pos);
      }
      return paths;
    }

    handle(nodes.filter(n -> switch n.pragma {
      case Some('block') | Some('namespace') | Some('paragraph'): true;
      case Some(_) | None: false;
    }));

    return types;
  }

  // @todo: throw an error if we properties other than the allowed ones.
  // @todo: The `@text` pragma is weird and should be rethought.
  public static function extractProperties(node:Node):Array<BlockTypeProperty> {
    var props = node.children.filter(child -> switch child.pragma {
      case Some('text') | Some('property'): true;
      default: false;
    });
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
  
  final types:Map<String, BlockType>;
  final root:BlockType;

  public function new(?types, ?root) {
    this.types = if (types != null) types else [];
    this.root = if (root != null) root else {
      name: '@root',
      isRoot: true,
      isParagraph: false,
      properties: [],
      children: types.filter(t -> t.isRoot).map(t -> ({
        alias: t.name,
        fullPath: t.name
      }:BlockTypeName))
    };
  }

  public function type(nodes:Array<Node>):Array<Block> {
    return typeNodes(nodes, root);
  }

  function typeNodes(nodes:Array<Node>, context:BlockType):Array<Block> {
    var blocks:Array<Block> = [];
    for (node in nodes) switch typeNode(node, context) {
      case None:
      case Some(block): blocks.push(block);
    }
    return blocks;
  }

  function typeNode(node:Node, context:BlockType):Option<Block> {
    return switch node.pragma {
      case Some(_):
        // @todo: allow inline types?
        throw new ParserException(
          'Unexpected pragma.',
          node.pos
        );
        None;
      case None:
        var typeName = if (node.block == Builtin.paragraph) {
          var name:BlockTypeName = null;
          for (type in context.children) {
            if (types.get(type.fullPath).isParagraph) {
              name = type;
              break;
            }
          }
          name;
        } else {
          context.children.find(c -> c.alias == node.block);
        }
        if (typeName == null) {
          throw new ParserException(
            'Invalid block: the block [' + node.block + '] is not allowed here or was not defined.',
            node.pos
          );
        }
        var type = types.get(typeName.fullPath);
        Some(createBlock(node, type));
    }
  }

  function createBlock(node:Node, type:BlockType):Block {
    var props:Map<String, Dynamic> = [];

    for (prop in node.properties) {
      var def = if (prop.name == Builtin.textProperty) {
        type.properties.find(def -> def.isText);
      } else {
        type.properties.find(def -> prop.name == def.name);
      }
      if (def == null) {
        throw new ParserException(
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
      props.set(def.name, value);
    }

    return {
      name: type.name,
      properties: props,
      children: typeNodes(node.children, type)
    };
  }
}