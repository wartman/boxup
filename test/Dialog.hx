import boxup.Block;
import boxup.Children;
import boxup.block.Paragraph;
import boxup.block.InlineText;

class Dialog implements Block {
  @prop var character:String;
  @prop var modifier:String = null;
  @children var children:Children<Paragraph, InlineText, Attached, Mood, Notes>;
}
