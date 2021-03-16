package boxup;

using Medic;

class TestParser implements TestCase {
  public function new() {}

  inline function getTokens(content:String) {
    return new Source('<test>', content).tokens.sure();
  }
  
  @:test('Simple parsing')
  public function testSimple() {
    var tokens = getTokens('
[Foo]
  a = b
    ');
    var parser = new Parser(tokens);
    var nodes = parser.parse().sure();
    nodes.length.equals(1);
    switch nodes[0].type {
      case Block(name): 
        name.equals('Foo');
      default:
        Assert.fail('Unexpected node type: ${nodes[0].type}');
    }
    nodes[0].getProperty('a').equals('b');
  }
  
  @:test('Block properties')
  public function testBlockProps() {
    var tokens = getTokens('[Foo a=b c=d]');
    var nodes = new Parser(tokens).parse().sure();
    nodes.length.equals(1);
    switch nodes[0].type {
      case Block(name): 
        name.equals('Foo');
      default:
        Assert.fail('Unexpected node type: ${nodes[0].type}');
    }
    nodes[0].getProperty('a').equals('b');
    nodes[0].getProperty('c').equals('d');
  }

  @:test('Block id')
  public function testBlockId() {
    var tokens = getTokens('[Foo/bar a=b c=d]');
    var nodes = new Parser(tokens).parse().sure();
    nodes.length.equals(1);
    nodes[0].id.value.equals('bar');
  }

  // @todo: oh god so much
  //        this is not the right way to test syntax: we should
  //        create a bunch of fixtures instead.
}
