package boxup.cli;

import boxup.Generator;

class DefinitionGenerator implements Generator<Definition> {
  public function new() {}

  public function generate(nodes:Array<Node>):GeneratorResult<Definition> {
    var def = Definition.generate(nodes);
    return {
      hasErrors: false,
      errors: [],
      result: def
    };
  }
}
