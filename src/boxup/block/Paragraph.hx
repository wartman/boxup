package boxup.block;

// @boxup.builtin
// @boxup.name('__internal.Paragraph')
// class Paragraph implements Block {
//   @children public var content:Children<Text>;
// }

@:genericBuild(boxup.block.ParagraphBuilder.build())
class Paragraph<Rest> {}
