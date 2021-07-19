package boxup;

using Medic;
using boxup.stream.StreamTools;

class TestParser implements TestCase {
  public function new() {}

  function process(content:String, next:(nodes:Array<Node>)->Void, ?handleError) {
    var scanner = new Scanner();

    scanner
      .pipe(new Parser())
      .getOutput()
      .handleError(
        handleError != null
          ? handleError
          : _ -> null
      )
      .finish(next);

    scanner.write(new Source('<test>', content));
  }
  
  @:test('Simple parsing')
  @:test.async()
  public function testSimple(done) {
    process('
[Foo]
  a = b
    ', nodes -> {
      nodes.length.equals(1);
      switch nodes[0].type {
        case Block(name): 
          name.equals('Foo');
        default:
          Assert.fail('Unexpected node type: ${nodes[0].type}');
      }
      nodes[0].getProperty('a').equals('b');
      done();
    });
  }

//   @:test('Properties and paragraphs can coexist')
//   @:test.async()
//   public function testPropsAndParagraphs(done) {
//     process('
// [Foo]
//   a = b

//   And a paragraph!
//     ', nodes -> {
//       nodes.length.equals(1);
//       nodes[0].children.length.equals(2);

//       switch nodes[0].type {
//         case Block(name): 
//           name.equals('Foo');
//         default:
//           Assert.fail('Unexpected node type: ${nodes[0].type}');
//       }
//       switch nodes[0].children[1].type {
//         case Paragraph: 
//           Assert.pass();
//         default:
//           Assert.fail('Unexpected node type: ${nodes[0].type}');
//       }
      
//       nodes[0].getProperty('a').equals('b');

//       done();
//     }, e -> {
//       e.toString().fail();
//       done();
//     });
//   }
  
  @:test('Block properties')
  @:test.async()
  public function testBlockProps(done) {
    process('[Foo a=b c=d]', nodes -> {
      nodes.length.equals(1);
      switch nodes[0].type {
        case Block(name): 
          name.equals('Foo');
        default:
          Assert.fail('Unexpected node type: ${nodes[0].type}');
      }
      nodes[0].getProperty('a').equals('b');
      nodes[0].getProperty('c').equals('d');
      done();
    });
  }

  @:test('Block id')
  @:test.async()
  public function testBlockId(done) {
    process('[Foo/bar a=b c=d]', nodes -> {
      nodes.length.equals(1);
      nodes[0].id.value.equals('bar');
      done();
    });
  }

  // @todo: oh god so much
  //        this is not the right way to test syntax: we should
  //        create a bunch of fixtures instead.
}
