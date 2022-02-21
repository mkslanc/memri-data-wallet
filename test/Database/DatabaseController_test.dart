import 'package:memri/controllers/database_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/core/services/database/demo_data.dart';
import 'package:memri/models/database/item_record.dart';

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

  test('testDefaultDataImport', () async {
    await DemoData.importDefaultData(
        databaseController: databaseController, throwIfAgainstSchema: true);
  });

  test('testDemoDataImport', () async {
    await DemoData.importDemoData(
        databaseController: databaseController, throwIfAgainstSchema: true);
  });

  test('testDataImport', () async {
    await DemoData.importDefaultData(
        databaseController: databaseController, throwIfAgainstSchema: true);
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
