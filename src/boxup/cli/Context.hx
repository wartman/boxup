package boxup.cli;

import boxup.definition.DefinitionCollection;

class Context {
  public final config:Config;
  public final definitions:DefinitionCollection;
  public final sources:SourceCollection;

  public function new(conifg, definitions, sources) {
    this.config = conifg;
    this.definitions = definitions;
    this.sources = sources;
  }
}
