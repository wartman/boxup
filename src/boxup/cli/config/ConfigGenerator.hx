package boxup.cli.config;

using haxe.io.Path;

using Lambda;

class ConfigGenerator implements Generator<BoxConfig> {
  final root:String;

  public function new(root) {
    this.root = root;
  }

  public function generate(nodes:Array<Node>, source:Source):Outcome<BoxConfig> {
    // Note: we're assuming this passed validation, so we're not checking
    //       that any requried blocks exist.
    var definitions = nodes.find(n -> n.type.equals(Block('Definitions')));
    var compileTasks = nodes.filter(n -> n.type.equals(Block('Compile')));
    return Ok({
      definitionSuffix: definitions.getProperty('suffix', 'd'),
      definitionRoot: Path.join([ root, definitions.getProperty('root') ]),
      compileTasks: [ for (task in compileTasks) {
        source: Path.join([ root, task.getProperty('source') ]),
        destination: Path.join([ root, task.getProperty('destination') ]),
        generator: task.getProperty('generator')
      } ]
    });
  }
}
