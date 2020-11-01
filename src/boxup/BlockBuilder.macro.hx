package boxup;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using haxe.macro.Tools;

class BlockBuilder {
  public static function build() {
    var cls = Context.getLocalClass().get();
    var fields = Context.getBuildFields();
    var decoders:Array<Expr> = [];
    var allowed:Array<Expr> = [];
    var blockName = cls.name;
    var hasChildren:Bool = false;
    var hasContent:Bool = false;
    var tp:TypePath = {
      pack: cls.pack,
      name: cls.name
    };

    if (cls.meta.has('boxup.name')) {
      var meta = cls.meta.extract('boxup.name');
      if (meta[0].params.length != 1) {
        Context.error('Name required', meta[0].pos);
      }

      switch meta[0].params[0].expr {
        case EConst(CString(s, _)): 
          blockName = s;
        default: 
          Context.error('Expected a String',  meta[0].params[0].pos);
      }
    }

    for (field in fields) switch field.kind {
      case FVar(t, e) if (field.meta.exists(f -> f.name == 'prop')):
        // todo: check that `t` is a valid field type??
        var name = field.name;
        var realType = t.toString();
        var casting = if (realType == 'String') {
          macro prop.value.value;
        } else if (realType == 'Int') {
          macro Std.parseInt(prop.value.value);          
        } else if (realType == 'Float') {
          macro Std.parseFloat(prop.value.value); 
        } else {
          macro cast prop.value.value;
        }
        var handleDefault = if (e != null) {
          macro this.$name = ${e};
        } else {
          macro throw new boxup.internal.ParserException(
            'The required property ' + $v{name} + ' was not provided',
            node.pos
          );
        }

        if (!field.access.contains(APublic)) {
          field.access.push(APublic);
        }

        allowed.push(macro $v{name});

        decoders.push(macro {
          var prop = Lambda.find(node.properties, f -> f.name == $v{name});
          if (prop == null) {
            ${handleDefault};
          } else if (prop.value.type != $v{realType}) {
            throw new boxup.internal.ParserException(
              'Invalid type: expected ' + $v{realType} + ' but was ' + prop.value.type,
              prop.value.pos
            );
          } else {
            this.$name = ${casting};
          }
        });
      
      case FVar(t, e) if (field.meta.exists(f -> f.name == 'children')):
        if (hasChildren) {
          Context.error(
            'Only one @children field is allowed per Block',
            field.pos
          );
        }
        
        hasChildren = true;

        if (!Context.unify(t.toType(), Context.getType('boxup.Parser.ParserBase'))) {
          Context.error(
            '@children fields must be boxup.Parser',
            field.pos
          );
        }

        var name = field.name;
        var pack = t.toType().follow().toString().split('.');
        var childrenName = pack.pop();
        var tp:TypePath = {
          pack: pack,
          name: childrenName
        };

        if (!field.access.contains(APublic)) {
          field.access.push(APublic);
        }
        field.kind = FVar(macro:Array<boxup.Block>);

        decoders.push(macro this.$name = {
          var parser = new $tp();
          parser.parse(node.children);
        });

      case FVar(t, e) if (field.meta.exists(f -> f.name == 'content')):
        if (hasContent) {
          Context.error(
            'Only one @content field is allowed per Block',
            field.pos
          );
        }
        
        hasContent = true;

        var name = field.name;

        if (!field.access.contains(APublic)) {
          field.access.push(APublic);
        }
        allowed.push(macro '__text');

        decoders.push(macro {
          var prop = Lambda.find(node.properties, f -> f.name == '__text');
          if (prop != null) this.$name = prop.value.value;
        });

      default:
    }

    fields = fields.concat((macro class {
      public static final __blockName = $v{blockName};
      public final pos:boxup.internal.Position;

      public static function __createBlock(node:boxup.internal.AstNode):boxup.Block {
        return new $tp(node);
      }

      public function new(node:boxup.internal.AstNode) {
        var allowedProps = [ $a{allowed} ];
        pos = node.pos;

        for (prop in node.properties) {
          if (!allowedProps.contains(prop.name)) {
            throw new boxup.internal.ParserException(
              'Invalid property: ' + prop.name,
              prop.pos
            );
          }
        }

        $b{decoders};
      }

    }).fields);

    return fields;
  }
}