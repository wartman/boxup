package boxup.definition;

class DefinitionCollectionValidator extends Validator {
  final collection:DefinitionCollection;

  public function new(collection) {
    this.collection = collection;
    super();
  }

  public function validate(nodes:Array<Node>) {
    (switch collection.findDefinition(nodes) {
      case Some(def): 
        def.validate(nodes);
      case None: 
        Ok(nodes);
    }:Result<Array<Node>>)
      .handleError(fail)
      .handleValue(_ -> pass(nodes));
  }
}