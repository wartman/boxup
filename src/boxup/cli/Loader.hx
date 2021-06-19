package boxup.cli;

import boxup.stream.Readable;

abstract class Loader extends Readable<Source> {
  final sources:SourceCollection;
  
  public function new(sources) {
    this.sources = sources;
    onData.add(this.sources.add);
  }

  abstract public function load():Void;
}
