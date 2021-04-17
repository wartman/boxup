package boxup.cli.nodes;

class FilteredNodeStream extends AbstractStream<Result<Source>, Chunk<Array<Node>>> {
  final manager:DefinitionManager;
  final allowedIds:Array<DefinitionId>;

  public function new(manager, allowedIds) {
    this.manager = manager;
    this.allowedIds = allowedIds;
    super();
  }

  public function write(source:Result<Source>) {
    source.handleValue(source -> {
      source.tokens
        .map(tokens -> new Parser(tokens).parse())
        .handleValue(nodes -> switch manager.resolveDefinitionId(nodes, source) {
          case Some(id) if (!allowedIds.contains(id) && !allowedIds.contains('*')):
            // noop
          case None if (!allowedIds.contains('*')): 
            // noop
          default:
            forward({
              result: Ok(nodes),
              source: source
            });
        }).handleError(error -> forward({
          result: Fail(error),
          source: source
        }));
    });
    source.handleError(error -> forward({
      result: Fail(error),
      source: Source.none()
    }));
  }
}
