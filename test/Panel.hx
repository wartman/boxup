import boxup.Block;
import boxup.Parser;
import boxup.block.Paragraph;

class Panel implements Block {
  @children var children:Parser<Dialog, Notes, Paragraph<Link, Emphasis>>;
}
