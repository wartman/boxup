package boxup.cli;

import boxup.cli.loader.BoxConfigLoader;
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
    var loader = new BoxConfigLoader(Sys.getCwd());
    var config = new ConfigStream([ for (key in generators.keys()) key ]);
    var writer = new FileWriter();

    Sys.println('');
    Sys.println('[Boxup]');
    Sys.println('Starting tasks...');

    config
      .map(new ContextStream(resolver))
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

    loader.pipe(config);
    loader.load();
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
