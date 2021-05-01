package boxup.cli;

import boxup.cli.writer.FileWriter;
import boxup.cli.loader.*;
import boxup.cli.resolver.*;
import boxup.cli.generator.*;
import boxup.reporter.VisualReporter;
import boxup.definition.DefinitionIdResolverCollection;

using boxup.cli.ContextStream;
using boxup.cli.TaskStream;
using boxup.cli.ReporterStream;
using boxup.cli.LoggingStream;

class App {
  final generators:GeneratorCollection<String>;
  final loaderFactory:(root:String)->Loader;
  final resolver:DefinitionIdResolverCollection;
  final reporter:Reporter;

  public function new(?generators, ?loaderFactory, ?resolver, ?reporter) {
    this.generators = generators == null
      ? [
        'html' => HtmlGenerator.new,
        'md' => MarkdownGenerator.new,
        'json' => _ -> new JsonGenerator()
      ] : generators;
    this.loaderFactory = loaderFactory != null
      ? loaderFactory
      : DirectoryLoader.new;
    this.resolver = resolver != null
      ? resolver
      : [
        new FileNameResolver(),
        new DefaultResolver('markup') // Fallback
      ];
    this.reporter = reporter == null
      ? new VisualReporter()
      : reporter;
  }

  public function run() {
    var loader = new BoxConfigLoader(Sys.getCwd());
    var writer = new FileWriter();
    
    Sys.println('');
    Sys.println('[Boxup]');
    Sys.println('Starting tasks...');
    
    loader.stream
      .pipeSourceIntoContext(
        generators.getNames(), 
        DirectoryLoader.new, 
        resolver
      )
      .pipeContextIntoTasks(generators)
      .pipeTasksThroughLogger()
      .pipeTaskIntoCompiler(loaderFactory)
      .pipeOutputThroughLogger()
      .pipeChunkThroughReporter(reporter)
      .into(writer);

    writer.onEnd.add(_ -> {
      Sys.println('------');
      Sys.println('Tasks complete.');
    });
    
    loader.run();
  }
}
