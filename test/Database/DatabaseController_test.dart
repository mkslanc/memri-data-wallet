import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/Controllers/Database/DemoData.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseController databaseController;

  setUp(() async {
    databaseController = DatabaseController(inMemory: true);
    await databaseController.init();
  });

  test('testDatabaseSetup', () async {
    var tables = await databaseController.databasePool
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();

    expect(tables.length, 6);
  });

  test('testDemoDataImport', () async {
    await DemoData.importDemoData(
        databaseController: databaseController, throwIfAgainstSchema: true);
  });

  tearDown(() async {
    databaseController.databasePool.close();
  });
}
