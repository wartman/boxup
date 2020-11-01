import boxup.Parser;
import boxup.cli.Compiler;
import boxup.cli.App;
import boxup.cli.FileLoader;
import boxup.cli.FileWriter;
import boxup.cli.DefaultReporter;

class Run {
  static function main() {
    var app = new App(new Compiler(
      new Parser<Comic, Page>(),
      new HtmlGenerator(),
      new FileLoader(Sys.getCwd()),
      new FileWriter(Sys.getCwd()),
      new DefaultReporter()
    ));
    app.run();
  }
}
