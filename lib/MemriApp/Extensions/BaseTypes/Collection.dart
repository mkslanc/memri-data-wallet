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

  List<T> compactMap<T>([T f(E e)?]) {
    return this.map<T>(f ?? (e) => e as T).where((element) => element != null).toList();
  }
}
