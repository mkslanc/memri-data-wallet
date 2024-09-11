import '../../core/models/item.dart';

class Binding<Value> {
  Value Function() get;
  void Function(Value val) set;

  Binding(this.get, this.set);

  factory Binding.forItem(Item item, String prop, [Value? defaultValue]) {
    return Binding(
        () => item.get<Value>(prop) ?? defaultValue as Value,
        (value) => item.set<Value>(prop, value)
    );
  }
}
