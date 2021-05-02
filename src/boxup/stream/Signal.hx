package boxup.stream;

typedef SignalListener<T> = (data:T)->Void;

abstract Signal<T>(Array<SignalListener<T>>) {
  public inline function new() {
    this = [];
  }

  public inline function add(listener:SignalListener<T>) {
    this.push(listener);
    return () -> remove(listener);
  }

  public inline function remove(listener:SignalListener<T>) {
    this.remove(listener);
  }

  public inline function emit(data:T) {
    for (cb in this) cb(data);
  }

  public inline function clear() {
    for (cb in this) this.remove(cb);
  }
}
