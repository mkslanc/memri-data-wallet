import 'package:collection/src/iterable_extensions.dart';

extension EnumExtension on Enum {
  String get inString => this.toString().split(".").last;

  static T? rawValue<T extends Enum>(List<T> values, String? value) =>
      values.firstWhereOrNull((val) => val.inString == value);
}
