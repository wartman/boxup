package boxup.cli.logger;

class OutputLogger extends AbstractStream<Chunk<Output>, Chunk<Output>> {
  public function write(chunk:Chunk<Output>) {
    chunk.result.handleValue(out -> {
      Sys.println('   Compiling: ${chunk.source.filename} into ${out.task.extension}');
    });
    forward(chunk);
  }
}
