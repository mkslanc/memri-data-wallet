import 'package:memri/controllers/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/core/services/database/property_database_value.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppController appController;
  setUp(() async {
    appController = AppController.shared;
    appController.databaseController.inMemory = true;
    await appController.databaseController.init();
    await appController.databaseController.importRequiredData(throwIfAgainstSchema: true);
    await appController.databaseController.setupWithDemoData(throwIfAgainstSchema: true);
  });

  test('testPluginAuthenticationFlow', () async {
    var record = ItemRecord(type: "PluginRun");
    await record.save();
    await record.setPropertyValue("status", PropertyDatabaseValueString("idle"));
    appController.pubSubController.startObservingItemProperty(
        item: record,
        property: "status",
        desiredValue: PropertyDatabaseValueString("userActionNeeded"),
        completion: (newValue, [error]) {
          if (newValue == null) {
            return;
          }
          print("got `userActionNeeded`");
          expect(newValue.value, equals("userActionNeeded"));

          appController.pubSubController.startObservingItemProperty(
              item: record,
              property: "status",
              desiredValue: PropertyDatabaseValueString("ready"),
              completion: (newValue, [error]) {
                if (newValue == null) {
                  return;
                }
                print("got `ready`");
                expect(newValue.value, equals("ready"));
              });
        });

    await record.setPropertyValue("status", PropertyDatabaseValueString("started"));
    print("`started` passed");
    await record.setPropertyValue("status", PropertyDatabaseValueString("userActionNeeded"));
    print("`userActionNeeded` passed");
    await record.setPropertyValue("status", PropertyDatabaseValueString("userActionNeeded"));
    print("`userActionNeeded` passed");
    await record.setPropertyValue("status", PropertyDatabaseValueString("ready"));
    print("`ready` passed");
  });

  test('testPluginAuthenticationFlow2', () async {
    var record = ItemRecord(type: "PluginRun");
    await record.save();
    await record.setPropertyValue("status", PropertyDatabaseValueString("idle"));
    appController.pubSubController.startObservingItemProperty(
        item: record,
        property: "status",
        desiredValue: null,
        completion: (newValue, [error]) async {
          if (newValue is PropertyDatabaseValueString) {
            var status = newValue.value;

            print("got `$status`");

            switch (status) {
              case "userActionNeeded":
                print("presentCVUforPlugin");
                break;
              default:
                break;
            }
            return;
          }
        });

    await record.setPropertyValue("status", PropertyDatabaseValueString("started"));
    print("`started` passed");
    await record.setPropertyValue("status", PropertyDatabaseValueString("userActionNeeded"));
    print("`userActionNeeded` passed");
    await record.setPropertyValue("status", PropertyDatabaseValueString("userActionNeeded"));
    print("`userActionNeeded` passed");
    await record.setPropertyValue("status", PropertyDatabaseValueString("ready"));
    print("`ready` passed");
  });

  tearDownAll(() async {
    appController.databaseController.databasePool.close();
  });
}
