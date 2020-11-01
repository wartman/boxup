import boxup.Block;
import boxup.Parser;
import boxup.block.Paragraph;

class Notes implements Block {
  @children var content:Parser<Paragraph<Link, Emphasis>>;
}
