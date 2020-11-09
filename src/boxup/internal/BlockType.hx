package boxup.internal;

typedef BlockType = {
  public final name:String;
  public final properties:Array<BlockTypeProperty>;
  public final children:Array<BlockTypeName>;
  public final isParagraph:Bool;
  public final isRoot:Bool;
}
