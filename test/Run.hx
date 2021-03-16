using Medic;

function main() {
  var runner = new Runner();
  runner.add(new boxup.TestParser());
  runner.add(new boxup.TestScanner());
  runner.run();  
}
