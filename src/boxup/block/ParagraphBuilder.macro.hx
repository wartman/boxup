package boxup.block;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;
using haxe.macro.Tools;

class ParagraphBuilder {
  public static function build() {
    return switch Context.getLocalType() {
      case TInst(_.get() => { name: 'Paragraph' }, params):
        buildParagraph(params);
      default:
        throw 'assert';
    }
  }

  public static function buildParagraph(params:Array<Type>):ComplexType {
    var pack = [ 'boxup', 'block' ];
    var name = 'Paragraph';
    var pos = Context.currentPos();
    var blocks:Array<Type> = [];

    if (params.length == 0) {
      name = name += '__Default';
    } else for (param in params) switch param {
      case TInst(t, _):
        if (!Context.unify(param, Context.getType('boxup.Block'))) {
          Context.error(
            'Paragraph params must be Blocks',
            pos
          );
        }
        name += '__' + param.toString().replace('.', '_');
        blocks.push(param);
      default:
        Context.error(
          'Paragraph params must be Blocks',
          pos
        );
    }

    if (!typeExists('boxup.block.${name}')) {
      blocks.push((macro:boxup.block.Text).toType());
      var type:ComplexType = TPath({
        pack: [ 'boxup' ],
        name: 'Parser',
        params: blocks.map(b -> TPType(b.toComplexType()))
      });

      Context.defineType({
        pack: pack,
        name: name,
        pos: pos,
        params: [],
        meta: [
          { name: 'boxup.name', params: [ macro '__internal.Paragraph' ], pos: pos }
        ],
        kind: TDClass(null, [{
          pack: [ 'boxup' ],
          name: 'Block',
          params: []
        }]),
        fields: (macro class {
          @children public var children:$type;
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