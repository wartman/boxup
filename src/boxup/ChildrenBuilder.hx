package boxup;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;
using haxe.macro.Tools;

class ChildrenBuilder {
  public static function build() {
    return switch Context.getLocalType() {
      case TInst(_.get() => { name: 'Children' }, params):
        buildChildren(params);
      default:
        throw 'assert';
    }
  }
  
  static function buildChildren(params:Array<Type>):ComplexType {
    var pack = [ 'boxup', 'parser' ];
    var name = 'Children';
    var pos = Context.currentPos();

    for (param in params) switch param {
      case TInst(_, _):
        if (!Context.unify(param, Context.getType('boxup.Block'))) {
          Context.error(
            'Parser params must be Blocks',
            pos
          );
        }
        name += '__' + param.toString().replace('.', '_');
      default:
        Context.error(
          'Parser params must be Blocks',
          pos
        );
    }
    
    if (!typeExists('boxup.parser.${name}')) {
      var parserTp:TypePath = {
        pack: [ 'boxup' ],
        name: 'Parser',
        params: params.map(t -> TPType(t.toComplexType()))
      };

      Context.defineType({
        pack: pack,
        name: name,
        pos: pos,
        params: [],
        kind: TDClass({
          pack: [ 'boxup' ],
          name: 'Children',
          sub: 'ChildrenBase',
          params: []
        }),
        fields: (macro class {
          
          public function new(nodes) {
            super(nodes, new $parserTp());
          }

        }).fields
      });
    }

    return TPath({
      pack: pack,
      name: name
    });
  }

  static function typeExists(name:String) {
    try {
      return Context.getType(name) != null;
    } catch (e:String) {
      return false;
    }
  }
}