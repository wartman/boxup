package boxup.cli;

import boxup.cli.reporter.VisualReporter;
import boxup.cli.writer.FileWriter;
import boxup.cli.logger.*;
import boxup.cli.generator.*;
import boxup.cli.resolver.*;

class App {
  public static function run(
    resolver:DefinitionIdResolverCollection,
    generators:Map<String, (definition:Definition)->Generator<String>>,
    reporter:Reporter
  ) {
    var configReader = new ConfigReader(Sys.getCwd(), [ for (key in generators.keys()) key ]);
    var context = new ContextStream(resolver);
    var writer = new FileWriter();

    Sys.println('');
    Sys.println('[Boxup]');
    Sys.println('Starting tasks...');

    context
      .map(new TaskStream(generators))
      .map(new TaskLogger())
      .map(new TaskRunnerStream())
      .map(new ReporterStream(reporter))
      .map(new OutputLogger())
      .pipe(writer);

    writer.onEnd.add(_ -> {
      Sys.println('------');
      Sys.println('Tasks complete.');
    });

    configReader.pipe(context);
    configReader.read();
  }

  public static function runWithGenerators(generators) {
    run(
      new DefinitionIdResolverCollection([
        new FileNameResolver(),
        new DefaultResolver('markup') // Fallback
      ]),
      generators,
      new VisualReporter()
    );
  }

  public static function runWithDefaults() {
    run(
      new DefinitionIdResolverCollection([
        new FileNameResolver(),
        new DefaultResolver('markup') // Fallback
      ]),
      [
        'html' => HtmlGenerator.new,
        'md' => MarkdownGenerator.new,
        'json' => _ -> new JsonGenerator()
      ],
      new VisualReporter()
    );
  }
}
