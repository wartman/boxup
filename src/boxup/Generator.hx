package boxup;

@:autoBuild(boxup.GeneratorBuilder.build())
interface Generator<T> {
  public function generate(blocks:Array<Block>):Array<T>;
}
