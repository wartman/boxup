import boxup.Block;

class Comic implements Block {
  @prop var title:String;
  @prop var author:String;
  @prop var version:Int;
  @prop var date:String; // should be Date -- todo
  @prop var firstPageNumber:Int;
}
