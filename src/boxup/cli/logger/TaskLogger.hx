package boxup.cli.logger;

class TaskLogger extends AbstractStream<Chunk<Task>, Chunk<Task>> {
  public function write(chunk:Chunk<Task>) {
    chunk.result.handleValue(task -> {
      Sys.println('------');
      Sys.println('Starting task: ${task.source} -> ${task.destination}');
    });
    forward(chunk);
  }
}
