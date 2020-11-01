import boxup.Block;
import boxup.Parser;
import boxup.block.Text;

// You don't need to use `boxup.block.Paragraph` to handle
// paragraphs -- you can just mark a Block with `boxup.paragraph`.
// This will work for `@boxup.text` and `@boxup.inlineText` too. 
@boxup.paragraph
class DialogParagraph implements Block {
  // Note that the children here are either normal text OR
  // are tagged blocks. You will need to have a Text block (either
  // the `boxup.blok.*` one or one you marked with `@boxup.text`)
  // for this to parse paragraphs correctly.
  @children var children:Parser<Text, Emphasis, Link, Mood>;
}
