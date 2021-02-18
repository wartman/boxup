package boxup.cli;

class DefaultReporter implements Reporter {
  public function new() {}

  public function report(errors:Array<Error>, source:Source) {
    for (e in errors) reportError(e, source);
  }

  function reportError(e:Error, source:Source) {
    // todo: visual error reporting! Generate some user-friendly
    //       messages too.
    Sys.println('ERROR: ${e.pos.file} [${e.pos.min}]');
    Sys.println('    ${e.message}');

    var pos = e.pos;
    var content = source.content;
    var start = if (pos.min > 50) pos.min - 50 else 0;
    var before = content.substring(start, pos.min);
    var err = content.substring(pos.min, pos.max);
    var after = content.substring(pos.max, pos.max + 50);
    
    Sys.println(before + '->' + err + after);
  }
}
