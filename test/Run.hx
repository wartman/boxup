import boxup.Block;
import boxup.cli.Generator;
import boxup.cli.App;
import boxup.cli.JsonGenerator;

class Run {
  static function main() {
    var app = new App(new JsonGenerator({ formated: true }));
    app.run();
  }
}

// class HtmlGenerator implements Generator {
//   public function new() {}

//   public function generate(blocks:Array<Block>):String {
//     return '';
//   }

// }