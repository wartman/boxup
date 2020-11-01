package boxup.cli;

class App {
  final compiler:Compiler;

  public function new(compiler) {
    this.compiler = compiler;
  }

  public function run() {
    switch Sys.args() {
      case [ src, dst ]:
        compiler.run(src, dst);
      default:
        Sys.println('Usage: [src] [dst]');
        Sys.exit(1);
    }
  }
}
