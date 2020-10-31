package boxup;

@:genericBuild(boxup.GeneratorBuilder.build())
interface Generator<T> {
  public function generate(blocks:Array<Block>):T;
}
