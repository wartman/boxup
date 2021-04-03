package boxup.cli;

import haxe.ds.Map;

class TaskStream extends StreamBase<Context, Array<Task>> {
  final generators:Map<String, (defintion:Definition)->Generator<String>>;

  public function new(generators) {
    this.generators = generators;
  }

  public function transform(result:Result<Context>, source:Source):Result<Array<Task>> {
    return result.map(ctx -> Ok(ctx.config.tasks.map(t -> ({
      context: ctx,
      source: t.source,
      destination: t.destination,
      generator: new GeneratorFactory(ctx.definitions, generators.get(t.generator)),
      filter: t.filter,
      extension: t.extension
    }:Task))));
  }
}
