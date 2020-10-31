import boxup.Block;
import boxup.Children;
import boxup.block.Paragraph;
import boxup.block.InlineText;

class Attached implements Block {
  @children var children:Children<Paragraph, InlineText, Mood, Notes>;
}
