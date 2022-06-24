extension NumExtension on num {
  String format([int decimals = 2]) {
    return toStringAsFixed(truncateToDouble() == this ? 0 : decimals);
  }
}
