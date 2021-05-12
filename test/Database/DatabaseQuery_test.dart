import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseQuery.dart';
import 'package:memri/MemriApp/Controllers/Database/DemoData.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseController databaseController;

  setUp(() async {
    databaseController = DatabaseController(inMemory: true);
    await databaseController.init();
    await DemoData.importDemoData(
        databaseController: databaseController, throwIfAgainstSchema: true);
  });

  test('testQuery', () {
    var queryDef =
        DatabaseQueryConfig(itemTypes: ["Note", "Photo"], pageSize: 1000, currentPage: 0);
    var result = queryDef.executeRequest(databaseController);
    result.listen(expectAsync1(
        (List<ItemRecord> records) => expect(records, isNot(records.length == 0)),
        max: -1));
  });

  test('testQueryWithConditions', () {
    var queryDef = DatabaseQueryConfig(
        itemTypes: [],
        pageSize: 1000,
        currentPage: 0,
        conditions: [
          DatabaseQueryConditionPropertyEquals(PropertyEquals("title", "A demo note")),
          DatabaseQueryConditionPropertyEquals(PropertyEquals("starred", true))
        ]);
    var result = queryDef.executeRequest(databaseController);
    result.listen(expectAsync1((List<ItemRecord> records) {
      expect(records.length, 1);
    }, max: -1));
  });

  test('testSearchQuery', () {
    var queryDef = DatabaseQueryConfig(
        itemTypes: ["Note", "Photo"], searchString: "demo", pageSize: 10, currentPage: 0);
    var result = queryDef.executeRequest(databaseController);
    result.listen(expectAsync1((List<ItemRecord> records) {
      expect(records.length, 1);
    }, max: -1));
  });

  test('testWriteInRead', () async {
    var queryDef = await databaseController.search("trailhead first");
    var result = queryDef[0];
    await result.setPropertyValue(
        "content", PropertyDatabaseValueString("TESTING 123"), databaseController);
  });

  tearDown(() async {
    databaseController.databasePool.close();
  });
}
