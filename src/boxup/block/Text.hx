package boxup.block;

@boxup.builtin
@boxup.name('__internal.Paragraph.Text')
class Text implements Block {
  @content public var content:String;
}
