package boxup;

import boxup.ErrorCollection;

@:using(boxup.Outcome.OutcomeTools)
enum Outcome<T> {
  Ok(data:T);
  Fail(error:ErrorCollection);
}

class OutcomeTools {
  public static function sure<T>(outcome:Outcome<T>):T {
    return switch outcome {
      case Ok(data): data;
      case Fail(error): throw error;
    }
  }

  public static function map<T, R>(outcome:Outcome<T>, transform:(data:T)->Outcome<R>):Outcome<R> {
    return switch outcome {
      case Ok(data): transform(data);
      case Fail(error): Fail(error);
    }
  }
}
