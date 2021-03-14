package boxup.cli;

using haxe.io.Path;
using sys.FileSystem;

class DynamicValidator implements Validator {
  final manager:DefinitionManager;

  public function new(manager) {
    this.manager = manager;  
  }

  public function validate(nodes:Array<Node>, source:Source):Outcome<Array<Node>> {
    return switch manager.findDefinition(nodes, source) {
      case Some(def): 
        def.validate(nodes, source);
      case None: 
        Ok(nodes);
    }
  }
}
