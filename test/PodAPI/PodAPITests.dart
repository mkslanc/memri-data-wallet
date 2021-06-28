import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIConnectionDetails.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIPayloads.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIRequests.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Controllers/Syncing/SyncController.dart';
import 'package:uuid/uuid.dart';

/// This connection config is used to connect to the pod for the tests. You can change url scheme/path/port etc here
var connectionConfig = PodAPIConnectionDetails(ownerKey: Uuid().v4(), host: "192.168.88.17");

/// These are used to create test items in the pod for use in later tests
var noteRowId = 100;
var importerRowId = 101;
var indexerRowId = 102;
var fileRowId = 103;

var noteUID = Uuid().v4();
var importerUID = Uuid().v4();
var indexerUID = Uuid().v4();
var fileUID = Uuid().v4();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Schema schema;
  late DatabaseController databaseController;
  late SyncController syncController;

  setupPodForTesting() async {
    var noteItem = ItemRecord(rowId: noteRowId, uid: noteUID, type: "Note");
    var indexerItem = ItemRecord(rowId: indexerRowId, uid: indexerUID, type: "Indexer");
    //var fileItem = ItemRecord(rowId: fileRowId, uid: fileUID, type: "File");

    Map<String, dynamic> testNoteItem = () {
      List<ItemPropertyRecord> testItemProperties = [
        ItemPropertyRecord(
            itemRowID: noteRowId,
            name: "content",
            value: PropertyDatabaseValueString("Test note content")),
        ItemPropertyRecord(
            itemRowID: noteRowId,
            name: "title",
            value: PropertyDatabaseValueString("Test note content"))
      ];

      return noteItem.mergeDict(properties: testItemProperties, schema: schema);
    }();

    Map<String, dynamic> testIndexerItem = () {
      List<ItemPropertyRecord> testItemProperties = [
        ItemPropertyRecord(
            itemRowID: indexerRowId,
            name: "repository",
            value: PropertyDatabaseValueString("indexerRepo")),
      ];

      return indexerItem.mergeDict(properties: testItemProperties, schema: schema);
    }();

    var bulkAction = PodAPIPayloadBulkAction(
        createItems: [testNoteItem, testIndexerItem],
        updateItems: [],
        deleteItems: [],
        createEdges: []);

    var request = PodAPIStandardRequest.bulkAction(bulkAction);
    await request.execute(connectionConfig);
  }

  setUpAll(() async {
    HttpOverrides.global = null;
    databaseController = DatabaseController(inMemory: true);
    syncController = SyncController(databaseController);
    await databaseController.init();
    schema = databaseController.schema;
    await databaseController.setupWithDemoData();
    await setupPodForTesting();
  });

  setUp(() async {});

  test('testGetAllItems', () async {
    var request = PodAPIStandardRequest.searchAction({});
    var networkCall = await request.execute(connectionConfig);
    var podItems = jsonDecode(networkCall.body);
    expect(podItems.length, greaterThan(1));
  });

  test('testSyncing', () async {
    syncController.currentConnection = connectionConfig;
    await syncController.sync(connectionConfig: connectionConfig);
    expect(syncController.lastError, equals(null));
  });
}
