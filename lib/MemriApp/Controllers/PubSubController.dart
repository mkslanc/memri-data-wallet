import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:moor/moor.dart';

import 'AppController.dart';
import 'Database/PropertyDatabaseValue.dart';

class ItemSubscription with EquatableMixin {
  ItemRecord item;
  String property;
  int retryCount;
  PropertyDatabaseValue? desiredValue;
  void Function(PropertyDatabaseValue?, [String?]) completion;
  StreamSubscription? streamSubscription;

  ItemSubscription(
      {required this.item,
      required this.property,
      this.retryCount = 0,
      required this.desiredValue,
      required this.completion});

  @override
  List<Object?> get props => [item.uid, property];
}

class PubSubController {
  static int pollInterval = 3;
  static int maxRetryAttempts = 10;

  Set<ItemSubscription> _subscribers = {};
  Set<StreamSubscription<List<dynamic>>> _subscriptions = {};
  DatabaseController databaseController;

  PubSubController(this.databaseController);

  startObservingItemProperty(
      {required ItemRecord item,
      required String property,
      required PropertyDatabaseValue? desiredValue,
      required void Function(PropertyDatabaseValue?, [String?]) completion}) {
    var subscription = ItemSubscription(
        item: item, property: property, desiredValue: desiredValue, completion: completion);
    _subscribers.add(subscription);
    _startObserver(subscription);
  }

  stopObservingItemProperty({required ItemRecord item, required String property}) {
    var subscription = _subscriptionForItem(item: item, property: property);
    if (subscription == null) {
      return;
    }
    _cancelSubscription(subscription: subscription);
  }

  ItemSubscription? _subscriptionForItem({required ItemRecord item, required String property}) {
    return _subscribers.firstWhereOrNull((element) => element.item.uid == item.uid);
  }

  _cancelSubscription({required ItemSubscription subscription, String? error}) {
    subscription.completion(null, error ?? "Cancelled");
    _subscribers.remove(subscription);
    if (subscription.streamSubscription != null) {
      subscription.streamSubscription?.cancel();
      _subscriptions.remove(subscription.streamSubscription);
    }
  }

  _checkSubscriptionFulfilled(
      {required dynamic itemProperty, required ItemSubscription subscription}) {
    var containsValue = _containsExpectedValue(
        itemProperty: itemProperty,
        itemType: subscription.item.type,
        property: subscription.property,
        expectedValue: subscription.desiredValue);
    if (containsValue) {
      subscription.completion(subscription.desiredValue);
      stopObservingItemProperty(item: subscription.item, property: subscription.property);
      return;
    }
  }

  _startObserver(ItemSubscription subscription) {
    var stream = databaseController.databasePool
        .itemPropertyRecordsCustomSelectStream("name = ? AND value = ? AND item = ?", [
      Variable(subscription.property),
      Variable(subscription.desiredValue?.value),
      Variable(subscription.item.rowId)
    ]);
    var streamSubscription = stream.listen((List<dynamic> records) {
      if (records.isNotEmpty) {
        _checkSubscriptionFulfilled(itemProperty: records[0], subscription: subscription);
      }
    });
    subscription.streamSubscription = streamSubscription;
    _subscriptions.add(streamSubscription);
  }

  bool _containsExpectedValue(
      {required dynamic itemProperty,
      required String itemType,
      required String property,
      required PropertyDatabaseValue? expectedValue}) {
    var decodableValue = itemProperty.value;
    if (decodableValue == null) {
      return false;
    }
    var schema = AppController.shared.databaseController.schema;
    var expectedType = schema.expectedPropertyType(itemType, property);
    if (expectedType == null) {
      return false;
    }

    var databaseValue = PropertyDatabaseValue.create(decodableValue, expectedType);
    return databaseValue == expectedValue;
  }
}
