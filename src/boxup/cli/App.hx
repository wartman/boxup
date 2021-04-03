package boxup.cli;

import boxup.cli.reporter.VisualReporter;
import boxup.cli.generator.*;
import boxup.cli.resolver.*;

class App {
  public static function run(
    resolver:DefinitionIdResolverCollection,
    generators:Map<String, (definition:Definition)->Generator<String>>,
    reporter:Reporter
  ) {
    var configReader = new ConfigReader(Sys.getCwd(), [ for (key in generators.keys()) key ]);
    
    configReader
      .pipe(new ContextStream(resolver))
      .pipe(new TaskStream(generators))
      .pipe(new ErrorStream(reporter))
      .into(new TaskWriter(reporter));

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
