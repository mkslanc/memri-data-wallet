import 'package:moor/moor.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  const DateTimeConverter();

  @override
  mapToDart(int? fromDb) {
    if (fromDb == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(fromDb);
  }

  @override
  mapToSql(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.millisecondsSinceEpoch;
  }
}
