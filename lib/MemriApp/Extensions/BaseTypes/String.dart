extension StringExtension on String {
  String? get nullIfBlank {
    return RegExp(r"^\s*$").hasMatch(this) ? null : this;
  }

  String capitalizingFirst() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  String titleCase() {
    return this.split(r"^\s*$").map((el) => el.capitalizingFirst()).join(" ");
  }

  String camelCaseToWords() {
    return this
        .replaceAllMapped(RegExp(r'/([A-Z])/g'), (match) {
          return ' ${match.group(1)}';
        })
        .toLowerCase()
        .capitalizingFirst();
  }
}
