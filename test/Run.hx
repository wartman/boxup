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

        Maybe like <this>[Link url = "some/url.png"]?

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
      var gen = new HtmlGenerator();

      trace(blocks);
      trace(gen.generate(blocks).join('\n'));
    } catch (e:ParserException) {
      report(e.pos, e.message, content);
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
