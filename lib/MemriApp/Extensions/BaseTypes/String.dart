extension StringExtension on String {
  String? get nullIfBlank {
    return RegExp(r"^\s*$").hasMatch(this) ? null : this;
  }

  String get capitalizingFirst {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
