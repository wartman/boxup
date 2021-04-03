package boxup.cli;

import haxe.ds.Option;

class GeneratorFactory<T> implements Generator<T> {
  final manager:DefinitionManager;
  final factory:(definition:Definition)->Generator<T>;
  final generators:Map<DefinitionId, Generator<T>> = [];

  public function new(manager, factory) {
    this.manager = manager;
    this.factory = factory;
  }
  
  public function generate(nodes:Array<Node>, source:Source):Result<T> {
    return switch getGenerator(nodes, source) {
      case Some(generator):
        generator.generate(nodes, source);
      case None:
        Fail(new Error('Could not find a definition for ${source.filename}', nodes[0].pos)); 
    }
  }

  function getGenerator(nodes:Array<Node>, source:Source):Option<Generator<T>> {
    return switch manager.resolveDefinitionId(nodes, source) {
      case Some(id):
        if (!generators.exists(id)) switch manager.getDefinition(id) {
          case Some(def):
            generators.set(id, factory(def));
          default:
        }
        var generator = generators.get(id);
        return generator != null 
          ? Some(generator)
          : None; 
      default:
        None;
    }
  }
}
