package boxup;

@:autoBuild(boxup.GeneratorBuilder.build())
interface Generator<T> {
  public function generate(blocks:Array<Block>):Array<T>;
  public function generateString(blocks:Array<Block>):String;
}
