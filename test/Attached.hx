import boxup.Block;
import boxup.Parser;
import boxup.block.InlineText;
import boxup.block.Paragraph;

class Attached implements Block {
  @children var children:Parser<Paragraph<Link, Emphasis>, InlineText, Mood, Notes>;
}
