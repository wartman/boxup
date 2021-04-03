package boxup.cli;

import boxup.cli.nodes.FilteredNodeStream;
import boxup.cli.reader.DirectoryReader;

@:structInit
class Task extends ReadableBase<String> {
  public final context:Context;
  public final source:String;
  public final destination:String;
  public final generator:Generator<String>;
  public final filter:Array<DefinitionId>;
  public final extension:String;

  public function handle(done:()->Void) {
    var reader = new DirectoryReader(source);
    
    reader
      .pipe(new FilteredNodeStream(context.definitions, filter))
      .pipe(new ValidatorStream(context.definitions))
      .pipe(new GeneratorStream(generator))
      .into(new Finalizer(dispatch));

    reader.onDrained(done);
    reader.read();
  }
}
