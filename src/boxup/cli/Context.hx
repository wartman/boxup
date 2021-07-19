package boxup.cli;

import boxup.definition.DefinitionCollection;

class Context {
  public final config:Config;
  public final definitions:DefinitionCollection;

  public function new(conifg, definitions) {
    this.config = conifg;
    this.definitions = definitions;
  }
}
