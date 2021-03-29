import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseQuery.dart';
import 'package:memri/MemriApp/Controllers/Database/DemoData.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseController databaseController;

  setUp(() async {
    databaseController = DatabaseController(inMemory: true);
    await databaseController.init();
    await DemoData.importDemoData(
        databaseController: databaseController, throwIfAgainstSchema: true);
  });

  test('testQuery', () async {
    var queryDef = DatabaseQueryConfig(
        itemTypes: ["Note", "Photo"], pageSize: 1000, currentPage: 0);
    var result = await queryDef.executeRequest(databaseController.databasePool);
    expect(result, isNot(result.length == 0));
  });

  tearDown(() async {
    databaseController.databasePool.close();
  });
}
