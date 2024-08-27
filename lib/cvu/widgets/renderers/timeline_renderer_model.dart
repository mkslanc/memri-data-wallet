import 'package:collection/collection.dart';
import 'package:jiffy/jiffy.dart';

import '../../../core/models/item.dart';
import '../../../utilities/helpers/calendar_helper.dart';

/// The model used to group and display data on the timeline
class TimelineRendererModel {
  late List<TimelineGroup> data;
  late final TimelineDetailLevel detailLevel;
  late final bool mostRecentFirst;

  late final DateTime? Function(Item) itemDateTimeResolver;

  static CalendarHelper calendarHelper = CalendarHelper();

  init(
      {required List<Item> dataItems,
      required TimelineDetailLevel detailLevel,
      required bool mostRecentFirst,
      required DateTime? Function(Item) itemDateTimeResolver}) {
    this.detailLevel = detailLevel;
    this.mostRecentFirst = mostRecentFirst;
    this.itemDateTimeResolver = itemDateTimeResolver;

    data = TimelineRendererModel.group(dataItems,
        itemDateTimeResolver: itemDateTimeResolver,
        level: detailLevel,
        mostRecentFirst: mostRecentFirst);
  }

  static List<TimelineGroup> group(List<Item> data,
      {required DateTime? Function(Item) itemDateTimeResolver,
      required TimelineDetailLevel level,
      required bool mostRecentFirst,
      int maxCount = 2}) {
    List<MapEntry<DateTime, Item>> dataPairs = data.map((dataItem) {
      var date = itemDateTimeResolver(dataItem);
      if (date == null) {
        return null;
      }
      return MapEntry(date, dataItem);
    })
        .whereType<MapEntry<DateTime, Item>>()
        .toList();

    var groupedByDetailLevel = Map<DateTime, List<MapEntry<DateTime, Item>>>();
    dataPairs.forEach((dataPair) {
      var units = level.relevantComponents;
      var date = calendarHelper.dateByUnit(dataPair.key, units);
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

    Set<Unit> largerComponents = Set.from(level.largerComponents);
    sortedGroups[0].isStartOf = largerComponents;
    for (var index = 1; index < sortedGroups.length; index++) {
      var date1 = Jiffy.parseFromDateTime(sortedGroups[index - 1].date);
      var date2 = Jiffy.parseFromDateTime(sortedGroups[index].date);

      sortedGroups[index].isStartOf = largerComponents.where((component) {
        return !date1.isSame(date2, unit: component);
      }).toSet();
    }

    return sortedGroups;
  }

  static List<TimelineElement> groupByType(List<MapEntry<DateTime, Item>> data,
      {required bool mostRecentFirst, required int maxCount}) {
    Map<String, List<MapEntry<DateTime, Item>>> groupedByType = Map();

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
  Set<Unit> isStartOf = Set();

  TimelineGroup({required this.date, required this.items});
}

class TimelineElement {
  final String itemType;
  final int index;
  final List<Item> items;
  final DateTime date;

  TimelineElement(
      {required this.itemType, required this.index, required this.items, required this.date});

  get isGroup => items.length > 0 && items.first != items.last;
}

enum TimelineDetailLevel { year, month, week, day, hour }

extension TimelineDetailLevelExtension on TimelineDetailLevel {
  List<Unit> get relevantComponents {
    switch (this) {
      case TimelineDetailLevel.year:
        return [Unit.year];
      case TimelineDetailLevel.month:
        return [Unit.year, Unit.month];
      case TimelineDetailLevel.week:
        return [
          //TODO week not implemented correctly
          Unit.week,
          Unit.year,
        ]; // Note yearForWeekOfYear is used to correctly account for weeks crossing the new year
      case TimelineDetailLevel.day:
        return [Unit.year, Unit.month, Unit.day];
      case TimelineDetailLevel.hour:
        return [Unit.year, Unit.month, Unit.day, Unit.hour];
    }
  }

  String get value => this.toString().split(".").last;

  static TimelineDetailLevel? init(String? value) =>
      TimelineDetailLevel.values.firstWhereOrNull((val) => val.value == value);

  List<Unit> get largerComponents {
    switch (this) {
      case TimelineDetailLevel.year:
        return [];
      case TimelineDetailLevel.month:
        return [Unit.year];
      case TimelineDetailLevel.week: //TODO week not implemented correctly
        return [
          Unit.year
        ]; // Note yearForWeekOfYear is used to correctly account for weeks crossing the new year
      case TimelineDetailLevel.day:
        return [Unit.year, Unit.month];
      case TimelineDetailLevel.hour:
        return [Unit.year, Unit.month, Unit.day];
    }
  }
}
