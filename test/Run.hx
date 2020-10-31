import boxup.Block;
import boxup.Parser;
import boxup.internal.Builtin;
import boxup.internal.AstNode;
import boxup.internal.Position;
import boxup.internal.ParserException;
import boxup.internal.AstParser;

using Lambda;
using StringTools;

class Run {
  static function main() {
    var test = new Parser<Comic, Page>();
    var content = '
[Comic]
    title = Example
    author = Peter Wartman
    version = 1
    date = 10/28/2020
    firstPageNumber = 1

[Page]

    [Notes]
        The first panel here should be big -- really
        get that stormy atmosphere.

    [Panel]
        We open on a dark and stormy night.
  
    [Panel]
        FRED turns to his friend.

        [Dialog character = FRED modifier = off]
            [Mood] Looking around nervously

            Hey Bob, it sure is <stormy>[Emphasis] out here.

            [Attached] Kind of scary.

        [Dialog character = "BOB BOBSTINE"]
            You got that right, friend.
    
    [Panel]
        There is a long and awkward silence.

[Page]

    [Panel]
        A lightning bolt comes out of nowhere and
        incinerates both characters. It is grisly
        and a bit horrifying.

        But also funny.

    [Panel]
        Fade to black.

        In a comic.

        You can figure it out.
        
 ';

    var parser = new AstParser({
      filename: 'test',
      content: content
    });
    
    try {
      var document = parser.parse();
      var blocks = test.parse(document.children);

      trace(blocks);

      var out:Array<String> = [];

      for (node in document.children) out.push(buildBlock(node));

      trace(out.join('\n'));
      // trace(Json.stringify(parser.parse(), '   '));
    } catch (e:ParserException) {
      report(e.pos, e.message, content);
    }
  }

  static function buildBlock(node:AstNode):String {
    return switch node.block {
      case 'Comic':
        var title = node.properties.find(p -> p.name == 'title').value.value;
        '<header>\n<h1>${title}</h1>\n</header>';
      case 'Dialog':
        var name = node.properties
          .find(p -> p.name == 'character')
          .value
          .value;
        '<div class="character character--${name.replace(' ', '-')}">\n' 
        + '<h3>${name}</h3>\n'
        + [ 
          for (node in node.children) buildBlock(node)
        ].filter(s -> s != null).join('\n') + '\n</div>';
      case 'Mood':
        '<i class="mood">' + [ 
          for (node in node.children) buildBlock(node)
        ].filter(s -> s != null).join('\n') + '</i>';
      case 'Emphasis':
        '<b>' + [ 
          for (node in node.children) buildBlock(node)
        ].filter(s -> s != null).join('\n') + '</b>';
      case 'Attached':
        '<span class="meta">Attached</span>\n<p>' + [ 
          for (node in node.children) buildBlock(node)
        ].filter(s -> s != null).join('\n') + '</p>';
      case Builtin.tagged:
        var value = node.properties.find(p -> p.name == '__tagged').value;
        var block = node.children[0];
        block.children.push({
          block: Builtin.inlineText,
          properties: [
            { name: '__text', value: value, pos: value.pos }
          ],
          children: [],
          pos: value.pos
        });
        buildBlock(block);
      case Builtin.paragraph:
        if (node.children.length == 0) return null;
        var content =  [ 
          for (node in node.children) buildBlock(node) 
        ].filter(s -> s != null).join('');
        if (content.length == 0) return null;
        '<p>${content}</p>';
      case Builtin.inlineText | Builtin.text:
        node.properties.find(p -> p.name == '__text').value.value;
      case name:
        '<div class="${name.toLowerCase()}">\n' + [ 
          for (node in node.children) buildBlock(node)
        ].filter(s -> s != null).join('\n') + '\n</div>';
    }
  }

  static function report(pos:Position, message:String, source:String) {    
    var start = if (pos.min > 50) pos.min - 50 else 0;
    var before = source.substring(start, pos.min);
    var err = source.substring(pos.min, pos.max);
    var after = source.substring(pos.max, pos.max + 50);

    trace(message);
    trace('\n' + before + '->' + err + after);
  }
}
