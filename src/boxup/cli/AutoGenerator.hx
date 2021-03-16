package boxup.cli;

import haxe.ds.Option;
import haxe.ds.Map;

class AutoGenerator<T> implements Generator<T> {
  final manager:DefinitionManager;
  final generators:Map<DefinitionId, (definition:Definition)->Generator<T>>;

  public function new(manager, generators) {
    this.manager = manager;
    this.generators = generators;
  }
  
  public function generate(nodes:Array<Node>, source:Source):Outcome<T> {
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
        var factory = generators.get(id);
        switch manager.loadDefinition(id) {
          case Some(def) if (factory != null): 
            Some(factory(def));
          case Some(def) if (generators.exists('*')):
            var factory = generators.get('*');
            Some(factory(def));
          default: 
            None;
        }
      default:
        None;
    }
  }
}
