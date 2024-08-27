extension Dictionary<E> on List<E> {
  static Map<Y, List<E>> groupBy<E, Y>(Iterable<E> itr, Y Function(E) fn) {
    return Map.fromIterable(itr.map(fn).toSet(),
        value: (i) => itr.where((v) => fn(v) == i).toList());
  }

  E? firstWhereOrNull(bool test(E element)) {
    //TODO https://github.com/dart-lang/sdk/issues/42947
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  List<T> compactMap<T>([T? f(E e)?]) {
    return this
        .map<T?>(f ?? (e) => e as T?)
        .where((element) => element != null)
        .whereType<T>()
        .toList();
  }

  List<T> addSeparator<T>(T f()) {
    return this.expand((element) sync* {
      yield f();
      yield element;
    }).skip(1).whereType<T>().toList();
  }
}

extension IndexedMapExtension<T> on List<T> {
  /// Groups elements into map by [keyOf].
  Map<K, T> toMapByKey<K>(K Function(T element) keyOf,
      [T Function(T element)? valueOf]) {
    var result = <K, T>{};
    for (var element in this) {
      result[keyOf(element)] = valueOf != null ? valueOf(element) : element;
    }
    return result;
  }

  /// Groups elements into lists by [keyOf].
  Map<K, List<T>> groupListsBy<K>(K Function(T element) keyOf) {
    var result = <K, List<T>>{};
    for (var element in this) {
      (result[keyOf(element)] ??= [])..add(element);
    }
    return result;
  }

  List<List<T>> partition(length) {
    return fold([[]], (grouped, element) {
      if (grouped.last.length == length) grouped.add([]);
      grouped.last.add(element);
      return grouped;
    });
  }
}

extension SetExtension<E> on Set<E> {
  E? firstWhereOrNull(bool test(E element)) {
    //TODO https://github.com/dart-lang/sdk/issues/42947
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
