package boxup.cli.nodes;

class FilteredNodeStream extends StreamBase<Array<Token>, Array<Node>> {
  final manager:DefinitionManager;
  final allowedIds:Array<DefinitionId>;

  public function new(manager, allowedIds) {
    this.manager = manager;
    this.allowedIds = allowedIds;
  }

  public function transform(tokens:Result<Array<Token>>, source:Source) {
    var result = tokens.map(tokens -> new Parser(tokens).parse());
    return switch result {
      case Ok(nodes):
        switch manager.resolveDefinitionId(nodes, source) {
          case Some(id) if (!allowedIds.contains(id) && !allowedIds.contains('*')):
            null;
          case None if (!allowedIds.contains('*')): 
            null;
          default:
            result;
        }
      case Fail(_): 
        result;
    }
  }
}
