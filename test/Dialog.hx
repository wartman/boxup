import boxup.Block;
import boxup.Parser;
import boxup.block.Paragraph;
import boxup.block.InlineText;

class Dialog implements Block {
  @prop var character:String;
  @prop var modifier:String = null;
  @children var children:Parser<Paragraph<Link, Emphasis>, InlineText, Attached, Mood, Notes>;
}
