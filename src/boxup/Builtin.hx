package boxup;

enum abstract Builtin(String) from String to String {
  var BRoot = '@root';
  var BItalic = '@italic';
  var BBold = '@bold';
  var BUnderlined = '@underlined';
  var BRaw = '@raw';
}
