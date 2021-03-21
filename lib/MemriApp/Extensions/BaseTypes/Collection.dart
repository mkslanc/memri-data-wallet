extension Dictionary<T> on List<T> {
    static Map<Y, List<T>> groupBy<T, Y>(Iterable<T> itr, Y Function(T) fn) {
        return Map.fromIterable(itr.map(fn).toSet(),
            value: (i) => itr.where((v) => fn(v) == i).toList());
    }
}