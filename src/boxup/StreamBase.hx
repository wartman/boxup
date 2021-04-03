package boxup;

abstract class StreamBase<In, Out> 
  extends ReadableBase<Out>
  implements Stream<In, Out> 
{
  final output:Array<StreamResult<Out>> = [];

  public function write(input:Result<In>, source:Source) {
    var result = transform(input, source);
    if (result != null) output.push({
      result: result,
      source: source
    });
  }

  abstract function transform(input:Result<In>, source:Source):Result<Out>;

  function handle(done:()->Void) {
    for (out in output) dispatch(out.result, out.source);
    done();
  }
}
