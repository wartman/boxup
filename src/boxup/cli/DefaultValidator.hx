package boxup.cli;

using haxe.io.Path;
using sys.FileSystem;

class DefaultValidator implements Validator {
  final manager:DefinitionManager;

  public function new(manager) {
    this.manager = manager;  
  }

  public function validate(nodes:Array<Node>, source:Source):Outcome<Array<Node>> {
    return switch manager.getDocumentType(source.filename) {
      case Some(type):
        switch manager.loadDefinition(type) {
          case Some(def): def.validate(nodes, source);
          case None: Ok(nodes);
        }
      case None: 
        Ok(nodes);
    }
  }
}
