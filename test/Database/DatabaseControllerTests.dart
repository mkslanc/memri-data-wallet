import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:test/test.dart';
import '../../lib/globals.dart' as globals;

void main() {
  late DatabaseController databaseController;

  setUp(() async {
    globals.isRunningTests = true;
    databaseController = DatabaseController();
    await databaseController.initDB();
  });

  test('testDatabaseSetup', () async {
    var tables = await databaseController.databasePool
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();

    expect(tables.length, 6);
  });
}
