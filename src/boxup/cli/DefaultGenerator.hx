package boxup.cli;

import boxup.cli.generator.HtmlGenerator;

class DefaultGenerator implements Generator<String> {
  var manager:DefinitionManager;

  public function new(manager) {
    this.manager = manager;
  }

  public function generate(nodes:Array<Node>, source:Source):Outcome<String> {
    return switch manager.getDocumentType(source.filename) {
      case Some(type):
         switch manager.loadDefinition(type) {
          case Some(def): 
            new HtmlGenerator(def).generate(nodes, source);
          case None:
            Fail(new Error('Could not find a definition for ${source.filename}', nodes[0].pos)); 
        }
      case None:
        Fail(new Error('Could not find a definition for ${source.filename}', nodes[0].pos)); 
    }
  }
}
