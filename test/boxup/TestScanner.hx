package boxup;

using Medic;
using boxup.stream.StreamTools;

class TestScanner implements TestCase {
  public function new() {}

  @:test('Scanning works')
  @:test.async
  public function testSimple(done) {
    var scanner = new Scanner();
    scanner.output.finish(tokens -> {
      tokens.length.equals(4);
      done();
    });
    scanner.write(new Source('<test>', '[Test]'));
  }
}
