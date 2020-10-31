import sys.io.File;
import boxup.Parser;
import Comic;

class Main {
  static function main() {
    var parser = new Parser<Comic, Page>();
    var file = File.getContent('../../example/data/comic-script.hxu');
    trace(parser.parse(file));
  }
}
