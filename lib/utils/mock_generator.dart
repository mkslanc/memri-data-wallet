import 'dart:math';

import 'package:memri/controllers/database_controller.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:faker/faker.dart';

import '../core/services/database/property_database_value.dart';
import '../models/database/item_property_record.dart';
import '../models/database/item_record.dart';

class MockDataGenerator {
  static generateMockData({required SchemaValueType valueType, String? property}) {
    var faker = Faker();
    switch (valueType) {
      case SchemaValueType.string:
        switch (property) {
          case "content":
            return faker.lorem.sentences(2).join();
          case "title":
            return faker.lorem.sentence();
          default:
            return faker.randomGenerator.string(1);
        }
      case SchemaValueType.bool:
        return Random().nextBool();
      case SchemaValueType.int:
        return Random().nextInt(1000000);
      case SchemaValueType.double:
        return Random().nextDouble();
      case SchemaValueType.datetime:
        return faker.date.dateTime(minYear: 1970, maxYear: 2040).millisecondsSinceEpoch;
      case SchemaValueType.blob:
        return faker.lorem.sentences(2).join();
    }
  }

  static generateMockItems(
      {int count = 10,
      required DatabaseController db,
      required Map<dynamic, dynamic> properties,
      required String itemType}) async {
    List<ItemPropertyRecord> itemProperties = [];
    for (var i = 0; i < count; i++) {
      var item = ItemRecord(type: itemType);
      await item.save(db.databasePool);

      properties.forEach((key, value) {
        var valueType = db.schema.expectedPropertyType(itemType, key);
        if (valueType != null) {
          var newValue =
              value ?? MockDataGenerator.generateMockData(valueType: valueType, property: key);
          itemProperties.add(ItemPropertyRecord(
              itemRowID: item.rowId!,
              name: key,
              value: PropertyDatabaseValue.create(newValue, valueType)));
        }
      });
      itemProperties.add(ItemPropertyRecord(
          itemRowID: item.rowId!,
          name: "isMock",
          value: PropertyDatabaseValue.create(true, SchemaValueType.bool)));
    }

    await db.databasePool.itemPropertyRecordInsertAll(itemProperties);
  }
}
