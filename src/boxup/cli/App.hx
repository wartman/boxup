package boxup.cli;

import boxup.cli.config.ConfigFinder;
import haxe.Exception;
import boxup.cli.definitions.CoreDefinitions.coreDefinitionLoader;
import boxup.cli.loader.*;
import boxup.cli.resolver.*;
import boxup.cli.generator.HtmlGenerator;

using Reflect;

// @todo: this needs work
class App {
  public static function runWithGenerators(generators) {
    var root = Sys.getCwd();
    var reporter = new DefaultReporter();
    var finder = new ConfigFinder(reporter, root);

    switch finder.findConfig() {
      case Some(config):
        var manager = new DefinitionManager(
          [
            new FileNameResolver(),
            new DefaultResolver('markup') // Fallback
          ],
          [
            new FileLoader({
              root: config.definitionRoot,
              suffix: config.definitionSuffix
            }),
            coreDefinitionLoader
          ], 
          reporter
        );

        try {
          for (compileTask in config.compileTasks) {
            var task = new Task(reporter, manager, compileTask, generators);
            task.run();
          }
        } catch (e) {
          Sys.println(e.message);
          Sys.exit(1);
        }

        Sys.exit(0);
      case None:
        Sys.println('Could not find config.box or encountered errors');
        Sys.exit(1);
    }
  }

  public static function runDefault() {
    runWithGenerators([
      'markup' => HtmlGenerator.new,
      '*' => HtmlGenerator.new
    ]);
  }
}
