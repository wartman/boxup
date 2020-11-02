package boxup;

@:autoBuild(boxup.GeneratorBuilder.build())
interface Generator<T> {
  public function generate(blocks:Array<Block>):Array<T>;
  // @todo: generateString is a bad idea I think
  public function generateString(blocks:Array<Block>):String;
}
