package boxup;

interface Stream<In, Out> 
  extends Writable<In> 
  extends Readable<Out> 
{}
