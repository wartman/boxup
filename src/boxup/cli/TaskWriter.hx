package boxup.cli;

import boxup.cli.writer.FileWriter;

class TaskWriter implements Writable<Array<Task>> {
  final reporter:Reporter;

  public function new(reporter) {
    this.reporter = reporter;
  }

  public function write(result:Result<Array<Task>>, source:Source) {
    switch result {
      case Ok(tasks): for (task in tasks) {
        task
          .pipe(new ErrorStream(reporter))
          .into(new FileWriter(task));
          
        task.read();
      }
      case Fail(_):
    }
  }
}
