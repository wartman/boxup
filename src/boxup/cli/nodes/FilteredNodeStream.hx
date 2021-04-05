package boxup.cli.nodes;

class FilteredNodeStream extends AbstractStream<Chunk<Array<Token>>, Chunk<Array<Node>>> {
  final manager:DefinitionManager;
  final allowedIds:Array<DefinitionId>;

  public function new(manager, allowedIds) {
    this.manager = manager;
    this.allowedIds = allowedIds;
    super();
  }

  public function write(chunk:Chunk<Array<Token>>) {
    chunk.result
      .map(tokens -> new Parser(tokens).parse())
      .handleValue(nodes -> switch manager.resolveDefinitionId(nodes, chunk.source) {
        case Some(id) if (!allowedIds.contains(id) && !allowedIds.contains('*')):
          // noop
        case None if (!allowedIds.contains('*')): 
          // noop
        default:
          forward({
            result: Ok(nodes),
            source: chunk.source
          });
      })
      .handleError(error -> forward({
        result: Fail(error),
        source: chunk.source
      }));
  }
}
