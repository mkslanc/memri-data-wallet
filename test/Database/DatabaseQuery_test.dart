import 'package:flutter_test/flutter_test.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/controllers/database_query.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/models/database/item_property_record.dart';
import 'package:memri/models/database/item_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseController databaseController;

  setUp(() async {
    databaseController = DatabaseController(inMemory: true);
    await databaseController.init();
    await databaseController.importRequiredData(throwIfAgainstSchema: true);
    await databaseController.setupWithDemoData(throwIfAgainstSchema: true);
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
    var queryDef = DatabaseQueryConfig(pageSize: 1000, currentPage: 0, conditions: [
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
    await result.setPropertyValue("content", PropertyDatabaseValueString("TESTING 123"),
        db: databaseController);
  });

  test('testSearchAfterInsert', () async {
    var newNote = ItemRecord(type: "Note");
    await newNote.save(databaseController.databasePool);
    await newNote.setPropertyValue("content", PropertyDatabaseValueString("TESTING123"),
        db: databaseController);
    var queryDef = await databaseController.search("TESTING123");
    expect(queryDef.length, equals(1));
  });

  test('testSearchAfterUpdate', () async {
    var queryDef = await databaseController.search("trailhead first");
    var result = queryDef[0];
    await result.setPropertyValue("content", PropertyDatabaseValueString("TESTING123"),
        db: databaseController);
    var searchResults = await databaseController.search("TESTING123");
    expect(searchResults.length, equals(1));
  });

  test('testSearchAfterDelete', () async {
    var queryDef = await databaseController.search("trailhead first");
    var result = queryDef[0];
    await result.setPropertyValue("content", null, db: databaseController);
    var searchResults = await databaseController.search("trailhead");
    expect(searchResults.length, equals(0));
  });

  test('testItemPropertyRecordInsertAll', () async {
    var item = ItemRecord(type: "Note");
    await item.save(databaseController.databasePool);

    List<ItemPropertyRecord> properties = [];
    properties.add(ItemPropertyRecord(
        itemRowID: item.rowId!, name: "title", value: PropertyDatabaseValueString("Test1")));

    await databaseController.databasePool.itemPropertyRecordInsertAll(properties);
    var propertiesBefore = await item.properties(databaseController);
    expect(propertiesBefore.length, 1);
    expect(propertiesBefore[0].$value.value, "Test1");

    properties = [
      ItemPropertyRecord(
          itemRowID: item.rowId!, name: "title", value: PropertyDatabaseValueString("Test2"))
    ];
    await databaseController.databasePool.itemPropertyRecordInsertAll(properties);
    var propertiesAfter = await item.properties(databaseController);
    expect(propertiesAfter.length, 1);
    expect(propertiesAfter[0].$value.value, "Test2");
  });

  tearDown(() async {
    await databaseController.databasePool.close();
    await databaseController.driftIsolate!.shutdownAll();
  });
}
