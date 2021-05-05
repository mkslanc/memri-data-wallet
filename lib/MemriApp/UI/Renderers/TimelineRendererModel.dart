//
// TimelineRendererModel.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:jiffy/jiffy.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Helpers/CalendarHelper.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

/// The model used to group and display data on the timeline

class TimelineRendererModel {
  late List<TimelineGroup> data;
  late final TimelineDetailLevel detailLevel;
  late final bool mostRecentFirst;

  late final Future<DateTime?> Function(ItemRecord) itemDateTimeResolver;

  static CalendarHelper calendarHelper = CalendarHelper();

  init(
      {required List<ItemRecord> dataItems,
      required TimelineDetailLevel detailLevel,
      required bool mostRecentFirst,
      required Future<DateTime?> Function(ItemRecord) itemDateTimeResolver}) async {
    this.detailLevel = detailLevel;
    this.mostRecentFirst = mostRecentFirst;
    this.itemDateTimeResolver = itemDateTimeResolver;

    data = await TimelineRendererModel.group(dataItems,
        itemDateTimeResolver: itemDateTimeResolver,
        level: detailLevel,
        mostRecentFirst: mostRecentFirst);
  }

  static Future<List<TimelineGroup>> group(List<ItemRecord> data,
      {required Future<DateTime?> Function(ItemRecord) itemDateTimeResolver,
      required TimelineDetailLevel level,
      required bool mostRecentFirst,
      int maxCount = 2}) async {
    List<MapEntry<DateTime, ItemRecord>> dataPairs = (await Future.wait(data.map((dataItem) async {
      var date = await itemDateTimeResolver(dataItem);
      if (date == null) {
        return null;
      }
      return MapEntry(date, dataItem);
    })))
        .whereType<MapEntry<DateTime, ItemRecord>>()
        .toList();

    var groupedByDetailLevel = Map<DateTime, List<MapEntry<DateTime, ItemRecord>>>();
    dataPairs.forEach((dataPair) {
      var units = level.relevantComponents;
      var date = calendarHelper.dateByUnits(dataPair.key, units);
      if (groupedByDetailLevel.containsKey(date)) {
        var val = groupedByDetailLevel[date];
        val!.add(dataPair);
      } else {
        groupedByDetailLevel[date] = [dataPair];
      }
    });

    List<TimelineGroup> sortedGroups = [];

    groupedByDetailLevel.forEach((date, items) {
      sortedGroups.add(TimelineGroup(
          date: date,
          items: TimelineRendererModel.groupByType(items,
              mostRecentFirst: mostRecentFirst, maxCount: maxCount)));
    });
    if (sortedGroups.length == 0) {
      return [];
    }
    sortedGroups.sort((a, b) => mostRecentFirst
        ? b.date.millisecondsSinceEpoch - a.date.millisecondsSinceEpoch
        : a.date.millisecondsSinceEpoch - b.date.millisecondsSinceEpoch);

    Set<Units> largerComponents = Set.from(level.largerComponents);
    sortedGroups[0].isStartOf = largerComponents;
    for (var index = 1; index < sortedGroups.length; index++) {
      var date1 = Jiffy(sortedGroups[index - 1].date);
      var date2 = sortedGroups[index].date;

      sortedGroups[index].isStartOf = largerComponents.where((component) {
        return !date1.isSame(date2, component);
      }).toSet();
    }

    return sortedGroups;
  }

  static List<TimelineElement> groupByType(List<MapEntry<DateTime, ItemRecord>> data,
      {required bool mostRecentFirst, required int maxCount}) {
    Map<String, List<MapEntry<DateTime, ItemRecord>>> groupedByType = Map();

    data.forEach((dataItem) {
      var groupedItem = groupedByType[dataItem.value.type];
      if (groupedItem == null) {
        groupedByType[dataItem.value.type] = [dataItem];
      } else {
        groupedItem.add(dataItem);
      }
    });

    List<TimelineElement> groups = [];

    groupedByType.forEach((type, itemsWithDate) {
      if (itemsWithDate.length > maxCount) {
        itemsWithDate.sort((a, b) => mostRecentFirst
            ? b.key.millisecondsSinceEpoch - a.key.millisecondsSinceEpoch
            : a.key.millisecondsSinceEpoch - b.key.millisecondsSinceEpoch);
        groups.add(TimelineElement(
            itemType: type,
            index: 0,
            items: itemsWithDate.map((dataItem) => dataItem.value).toList(),
            date: itemsWithDate.asMap()[0]?.key ?? DateTime.now()));
      } else {
        groups.addAll(itemsWithDate.mapIndexed((index, item) =>
            TimelineElement(itemType: type, index: index, items: [item.value], date: item.key)));
      }
    });

    groups.sort((a, b) => mostRecentFirst
        ? b.date.millisecondsSinceEpoch - a.date.millisecondsSinceEpoch
        : a.date.millisecondsSinceEpoch - b.date.millisecondsSinceEpoch);

    return groups;
  }
}

class TimelineGroup {
  final DateTime date;
  final List<TimelineElement> items;

  // Used to store whether this is the first entry in year/month/day etc (for use in rendering supplementaries)
  Set<Units> isStartOf = Set();

  TimelineGroup({required this.date, required this.items});
}

class TimelineElement {
  final String itemType;
  final int index;
  final List<ItemRecord> items;
  final DateTime date;

  TimelineElement(
      {required this.itemType, required this.index, required this.items, required this.date});

  get isGroup => items[0] != items[items.length - 1];
}

enum TimelineDetailLevel { year, month, week, day, hour }

extension TimelineDetailLevelExtension on TimelineDetailLevel {
  List<Units> get relevantComponents {
    switch (this) {
      case TimelineDetailLevel.year:
        return [Units.YEAR];
      case TimelineDetailLevel.month:
        return [Units.YEAR, Units.MONTH];
      case TimelineDetailLevel.week:
        return [
          //TODO week not implemented correctly
          Units.WEEK,
          Units.YEAR,
        ]; // Note yearForWeekOfYear is used to correctly account for weeks crossing the new year
      case TimelineDetailLevel.day:
        return [Units.YEAR, Units.MONTH, Units.DAY];
      case TimelineDetailLevel.hour:
        return [Units.YEAR, Units.MONTH, Units.DAY, Units.HOUR];
    }
  }

  String get value => this.toString().split(".").last;

  static TimelineDetailLevel? init(String? value) =>
      TimelineDetailLevel.values.firstWhereOrNull((val) => val.value == value);

  List<Units> get largerComponents {
    switch (this) {
      case TimelineDetailLevel.year:
        return [];
      case TimelineDetailLevel.month:
        return [Units.YEAR];
      case TimelineDetailLevel.week: //TODO week not implemented correctly
        return [
          Units.YEAR
        ]; // Note yearForWeekOfYear is used to correctly account for weeks crossing the new year
      case TimelineDetailLevel.day:
        return [Units.YEAR, Units.MONTH];
      case TimelineDetailLevel.hour:
        return [Units.YEAR, Units.MONTH, Units.DAY];
    }
  }
}
