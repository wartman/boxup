import boxup.Block;
import boxup.Parser;
import boxup.block.Paragraph;
import boxup.block.InlineText;

class Mood implements Block {
  @prop var description:String = 'mood';
  @children var children:Parser<Paragraph<Link, Emphasis>, InlineText>;
}

