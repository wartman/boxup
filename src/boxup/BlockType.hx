package boxup;

using Lambda;

@:structInit
class BlockType {
  public final name:String;
  public final properties:Array<BlockTypeProperty>;
  public final children:Array<BlockTypeName>;
  public final isParagraph:Bool;
  public final isRoot:Bool;

  public function requiredProperties() {
    return properties.filter(p -> p.isRequired).map(p -> p.name);
  }
}
