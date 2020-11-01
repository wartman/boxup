package boxup;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using haxe.macro.Tools;

class GeneratorBuilder {
  public static function build() {
    var cls = Context.getLocalClass().get();
    var fields = Context.getBuildFields();
    var builders:Array<Expr> = [];

    // This seems super fragile. 
    var ret = cls.interfaces
      .find(i -> i.t.get().name == 'Generator')
      .params[0].toComplexType();

    for (field in fields) switch field.kind {
      case FFun(func) if (field.meta.exists(m -> m.name == 'generate')):
        var args = func.args;
        var name = field.name;

        if (args.length != 1) {
          Context.error('@generate methods must have one argument', field.pos);
        }

        var ct = args[0].type;

        if (ct == null) {
          Context.error('@generate argument type may not be inferred', field.pos);
        }

        var type = ct.toType().follow();
        
        if (!type.unify(Context.getType('boxup.Block'))) {
          Context.error('@generate argumant must be a boxup.Block', field.pos);
        }

        var condition = Context.parseInlineString('Std.is(block, ${type.toString()})', field.pos);
        builders.push(macro if (${condition}) return this.$name(cast block));
      default:
    }

    fields = fields.concat((macro class {
      public function generate(blocks:Array<boxup.Block>):Array<$ret> {
        function __buildInternal(block:boxup.Block) {
          $b{builders};
          throw new boxup.internal.ParserException(
            'Cannot generate block: ' + Type.getClassName(Type.getClass(block)),
            block.pos
          );
        }

        return [ for (block in blocks) __buildInternal(block) ];
      }
    }).fields);

    return fields;
  }
}