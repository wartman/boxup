package boxup.block;

@boxup.builtin
@boxup.name('__internal.InlineText')
class InlineText implements Block {
  @content public var __text:String;
}
