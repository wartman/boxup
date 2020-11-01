import boxup.Block;
import boxup.Parser;

class Page implements Block {
  @children var content:Parser<Panel, Notes>;
}
