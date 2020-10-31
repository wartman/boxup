package boxup.block;

// todo: need to figure out how to allow
//       this to parse any tagged blocks?
@boxup.name('__internal.Tagged')
class Tagged implements Block {
  @prop public var __tagged:String;
}
