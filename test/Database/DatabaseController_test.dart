import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/Controllers/Database/DemoData.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

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

    expect(tables.length, 11);
  });

  test('testDemoDataImport', () async {
    await DemoData.importDemoData(
        databaseController: databaseController, throwIfAgainstSchema: true);
  });

  test('testSearch', () async {
    await DemoData.importDemoData(
        databaseController: databaseController, throwIfAgainstSchema: true);
    List<ItemRecord> results = await databaseController.search("trailhead first");
    expect(results.length, 1);
    expect(results[0].type, "Note");
  });

  tearDown(() async {
    databaseController.databasePool.close();
  });
}
