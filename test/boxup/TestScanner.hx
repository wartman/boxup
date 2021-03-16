package boxup;

using Medic;

class TestScanner implements TestCase {
  public function new() {}

  @:test('Scanning works')
  public function testSimple() {
    var source = new Source('<test>', '[Test]');
    // note: Source scans tokens internally for the moment, which is a bit odd.
    switch source.tokens {
      case Ok(tokens):
        tokens.length.equals(4);
      case Fail(error):
        Assert.fail('Could not tokenize:' + error.toString());
    }
  }
}
