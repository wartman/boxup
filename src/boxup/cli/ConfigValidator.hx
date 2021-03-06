package boxup.cli;

import boxup.Builtin;
import boxup.definition.Definition;

class ConfigValidator extends Validator{
  public static function create(allowedGenerators:Array<String>) {
    return new Definition('config', [
      {
        name: BRoot,
        properties: [],
        children: [
          { name: 'Definitions', required: true, multiple: false },
          { name: 'Compile' }
        ]
      },
      {
        name: 'Definitions',
        properties: [
          { name: 'source', required: true },
          { name: 'suffix', required: false }
        ],
        children: []
      },
      {
        name: 'Compile',
        properties: [
          { name: 'source', required: true },
          { name: 'destination', required: true },
          { name: 'extension' },
          { name: 'generator', required: true, allowedValues: allowedGenerators },
          { name: 'filter', required: true }
        ],
        children: []
      }
    ], []);
  }

  final definition:Definition;

  public function new(definition) {
    this.definition = definition;
    super();
  }

  public function validate(nodes:Array<Node>) {
    definition.validate(nodes)
      .handleError(fail)
      .handleValue(_ -> pass(nodes));
  }
}
