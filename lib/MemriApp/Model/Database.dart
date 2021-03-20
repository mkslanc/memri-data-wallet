import 'package:moor/moor.dart';


part 'Database.g.dart';

@UseMoor(
  include: {'tables.moor'},
)
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
    );
  }

  Future<Item> itemRecordFetchWithUID(String uid) {
    return (select(items)..where((t) => t.id.equals(uid))).getSingle();
  }
}