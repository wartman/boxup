package boxup.cli.loader;

class CompoundLoader extends ReadStream<Result<Source>> implements Loader {
  final reader:CompoundReadStream<Result<Source>>;
  final loaders:Array<Loader>;

  public function new(loaders) {
    this.loaders = loaders;
    this.reader = new CompoundReadStream(cast loaders);
    this.reader.onData.add(onData.emit);
    this.reader.onClose.add(_ -> close());
    super();
  }

  public function load() {
    for (loader in loaders) loader.load();
  }  
}
