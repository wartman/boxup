import boxup.cli.generator.JsonGenerator;
import boxup.cli.*;

class Run {
  static function main() {
    switch App.createFromBoxuprc(
      new JsonGenerator(),
      new FileLoader(Sys.getCwd()),
      new FileWriter(Sys.getCwd()),
      new DefaultReporter()
    ) {
      case Some(app): app.run();
      case None:
    }
    // var app = new App(new Compiler(
    //   new Parser<Comic, Page>(),
    //   new HtmlGenerator(),
    //   new FileLoader(Sys.getCwd()),
    //   new FileWriter(Sys.getCwd()),
    //   new DefaultReporter()
    // ));
    // app.run();
  }
}
