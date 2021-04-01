extension StringExtension on String {
  String? get nullIfBlank {
    return RegExp(r"^\s*$").hasMatch(this) ? null : this;
  }
}
