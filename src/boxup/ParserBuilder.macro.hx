package boxup;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;
using haxe.macro.Tools;

class ParserBuilder {
  public static function build() {
    return switch Context.getLocalType() {
      case TInst(_.get() => { name: 'Parser' }, params):
        buildParser(params);
      default:
        throw 'assert';
    }
  }

  static function buildParser(params:Array<Type>):ComplexType {
    var pack = [ 'boxup', 'parser' ];
    var name = 'Parser';
    var blocks:Array<Expr> = [];
    var pos = Context.currentPos();

    // Todo: this will fail if we're dealing with module subtypes.
    //       I'm sure there's a better way...
    for (param in params) switch param {
      case TInst(_, _) | TType(_, _):
        if (!Context.unify(param.follow(), Context.getType('boxup.Block'))) {
          Context.error(
            'Parser params must be Blocks',
            pos
          );
        }
        name += '__' + param.toString().replace('.', '_');
        blocks.push(macro blockTypes.push($p{param.toString().split('.')}));
      default:
        Context.error(
          'Parser params must be Blocks',
          pos
        );
    }

    if (!typeExists('boxup.parser.${name}')) {
      Context.defineType({
        pack: pack,
        name: name,
        pos: pos,
        params: [],
        kind: TDClass({
          pack: [ 'boxup' ],
          name: 'Parser',
          sub: 'ParserBase',
          params: []
        }),
        fields: (macro class {
          
          public function new() {
            $b{blocks};
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
