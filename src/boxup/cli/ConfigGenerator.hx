package boxup.cli;

using haxe.io.Path;
using Lambda;
using StringTools;

class ConfigGenerator extends Generator<Config> {
  public function generate(nodes:Array<Node>) {
    var definitions = nodes.find(n -> n.type.equals(Block('Definitions')));
    var compileTasks = nodes.filter(n -> n.type.equals(Block('Compile')));
    var root = nodes[0].pos.file.directory();

    output.end({
      definitionSuffix: definitions.getProperty('suffix', 'd'),
      definitionRoot: Path.join([ root, definitions.getProperty('source') ]),
      tasks: [ for (task in compileTasks) {
        source: Path.join([ root, task.getProperty('source') ]),
        destination: Path.join([ root, task.getProperty('destination') ]),
        generator: task.getProperty('generator'),
        filter: task.getProperty('filter').split(',').map(s -> s.trim()),
        extension: task.getProperty('extension', task.getProperty('generator'))
      } ]
    });
  }
}
