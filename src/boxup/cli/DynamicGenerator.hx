package boxup.cli;

import haxe.ds.Option;
import haxe.ds.Map;

class DynamicGenerator implements Generator<String> {
  final resolver:Resolver;
  final manager:DefinitionManager;
  final generators:Map<String, (definition:Definition)->Generator<String>>;

  public function new(resolver, manager, generators) {
    this.resolver = resolver;
    this.manager = manager;
    this.generators = generators;
  }
  
  public function generate(nodes:Array<Node>, source:Source):Outcome<String> {
    return switch getGenerator(nodes, source) {
      case Some(generator):
        generator.generate(nodes, source);
      case None:
        Fail(new Error('Could not find a definition for ${source.filename}', nodes[0].pos)); 
    }
  }

  function getGenerator(nodes:Array<Node>, source:Source):Option<Generator<String>> {
    return switch resolver.resolveDefinitionType(nodes, source) {
      case Some(type):
        var factory = generators.get(type);
        switch manager.loadDefinition(type) {
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
