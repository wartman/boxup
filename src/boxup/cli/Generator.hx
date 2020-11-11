package boxup.cli;

interface Generator {
  public function generate(blocks:Array<Block>):String;
}
