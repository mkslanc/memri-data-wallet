class Binding<Value> {
  Value Function() get;
  void Function(Value val) set;

  Binding(this.get, this.set);
}

class FutureBinding<Value> {
  Future<Value> Function() get;
  Future<void> Function(Value val) set;

  FutureBinding(this.get, this.set);
}
