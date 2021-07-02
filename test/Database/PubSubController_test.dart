import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppController appController;
  setUp(() async {
    appController = AppController.shared;
    await appController.databaseController.init();
    await appController.databaseController.importRequiredData(throwIfAgainstSchema: true);
    await appController.databaseController.setupWithDemoData(throwIfAgainstSchema: true);
  });

  test('testPluginAuthenticationFlow', () async {
    var record = ItemRecord(type: "StartPlugin");
    await record.save();
    await record.setPropertyValue("state", PropertyDatabaseValueString("idle"));
    appController.pubsubController.startObservingItemProperty(
        item: record,
        property: "state",
        desiredValue: PropertyDatabaseValueString("userActionNeeded"),
        completion: (newValue, [error]) {
          if (newValue == null) {
            return;
          }
          print("got `userActionNeeded`");
          expect(newValue.value, equals("userActionNeeded"));

          appController.pubsubController.startObservingItemProperty(
              item: record,
              property: "state",
              desiredValue: PropertyDatabaseValueString("ready"),
              completion: (newValue, [error]) {
                if (newValue == null) {
                  return;
                }
                print("got `ready`");
                expect(newValue.value, equals("ready"));
              });
        });

    await record.setPropertyValue("state", PropertyDatabaseValueString("started"));
    print("`started` passed");
    await record.setPropertyValue("state", PropertyDatabaseValueString("userActionNeeded"));
    print("`userActionNeeded` passed");
    await record.setPropertyValue("state", PropertyDatabaseValueString("ready"));
    print("`ready` passed");

    var recordNotd = ItemRecord(type: "Note");
    await recordNotd.save();
    await recordNotd.setPropertyValue("title", PropertyDatabaseValueString("by Ani"));
  });

  tearDown(() async {
    appController.databaseController.databasePool.close();
  });
}
