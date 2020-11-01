import boxup.Block;

class Comic implements Block {
  @prop public var title:String;
  @prop public var author:String;
  @prop public var version:Int;
  @prop public var date:String; // should be Date -- todo
  @prop public var firstPageNumber:Int;
}
