class Binding<Value> {
  Value Function() get;
  void Function(Value val) set;

  Binding(this.get, this.set);
}
