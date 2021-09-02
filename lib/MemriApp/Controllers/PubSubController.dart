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
    stopObservingItemProperty(item: item, property: property);
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
    _removeSubscription(subscription);
  }

  _removeSubscription(ItemSubscription subscription) {
    _subscribers.remove(subscription);
    removeStreamSubscription(subscription);
    var streamSubscription = subscription.streamSubscription;
    if (streamSubscription != null) {
      streamSubscription.cancel();
      _subscriptions.remove(streamSubscription);
    }
  }

  _checkSubscriptionFulfilled(
      {required List<dynamic> dicts, required ItemSubscription subscription}) async {
    var dict = dicts.asMap()[0];
    if (dict == null) {
      return;
    }

    var newValue = _propertyValueFromDict(
        dict: dict, type: subscription.item.type, property: subscription.property);

    if (newValue == null) {
      _cancelSubscription(subscription: subscription, error: "Property not found");
      return;
    }
    subscription.completion(newValue, null);

    // If we have expected value to look for, check if new value is same as that of expected value
    var expectedValue = subscription.desiredValue;
    if (expectedValue == newValue) {
      _removeSubscription(subscription);
    }
  }

  _startObserver(ItemSubscription subscription) {
    var query = "name = ? AND item = ?";
    var binding = [Variable(subscription.property), Variable(subscription.item.rowId)];
    if (subscription.desiredValue != null) {
      query += " AND value = ?";
      binding.add(Variable(subscription.desiredValue!.value));
    }
    var stream =
        databaseController.databasePool.itemPropertyRecordsCustomSelectStream(query, binding);
    var streamSubscription = stream.listen((List<dynamic> records) {
      if (records.isNotEmpty) {
        _checkSubscriptionFulfilled(dicts: records, subscription: subscription);
      }
    });
    subscription.streamSubscription = streamSubscription;
    _subscriptions.add(streamSubscription);
  }

  PropertyDatabaseValue? _propertyValueFromDict(
      {required String property, required String type, required dynamic dict}) {
    var decodableValue = dict.value;
    if (decodableValue == null) {
      return null;
    }

    var schema = AppController.shared.databaseController.schema;
    var expectedType = schema.expectedPropertyType(type, property);
    if (expectedType == null) {
      return null;
    }

    return PropertyDatabaseValue.create(decodableValue, expectedType);
  }

  removeStreamSubscription(ItemSubscription subscription) {
    var streamSubscription = subscription.streamSubscription;
    if (streamSubscription != null) {
      streamSubscription.cancel();
      _subscriptions.remove(streamSubscription);
    }
  }

  reset() {
    _subscribers.forEach((subscription) {
      removeStreamSubscription(subscription);
    });
    _subscribers = {};
  }
}
