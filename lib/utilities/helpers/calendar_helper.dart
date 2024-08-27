import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

/// This struct contains a collection of useful functions for working with dates/times
class CalendarHelper {
  /// The calendar to use for calculations. This defaults to the users system calendar
  //var calendar = Calendar.current

  String get dayFormatter {
    return "d";
  }

  String get monthFormatter {
    return "MMM";
  }

  String get monthYearFormatter {
    return "MMM y";
  }

  /// Get an array of dates representing the start of each month in the specified period
  List<DateTime> getMonths(DateTime startDate, DateTime endDate) {
    var startDateJiffy = Jiffy.parseFromDateTime(startDate);
    var endDateJiffy = Jiffy.parseFromDateTime(endDate);
    if (endDateJiffy.isBefore(startDateJiffy)) {
      return [];
    }
    var firstMonth = startOfMonth(startDate);
    var lastMonth = startOfMonth(endDate);

    List<DateTime> dates = [];
    var date = firstMonth;
    do {
      dates.add(date.dateTime);
      date = date.add(months: 1);
    } while (date.isSameOrBefore(lastMonth));

    return dates;
  }

  /// Get an array of dates representing the start of each day during the specified period
  List<DateTime> getDays(DateTime month) {
    var monthEnd = endOfMonth(month);
    List<DateTime> dates = [];
    var date = monthEnd;
    do {
      dates.add(date.dateTime);
      date = date.add(hours: 1);
    } while (monthEnd.isSameOrAfter(date));

    return dates;
  }

  /// Get an array of dates representing the start of each day in the specified period with nil values appended to the start in order to make index 0 represent the first day of a week
  /// (useful for padding the start of the month with empty cells in a calendar view)
  List<DateTime?> getPaddedDays(DateTime month) {
    var weekdayAtStart = startOfMonth(month).dayOfWeek;
    var monthEnd = endOfMonth(month);
    var adjustedWeekday = weekdayAtStart;
    List<DateTime?> dates = [];
    for (var i = 1; i < adjustedWeekday; i++) {
      dates.add(null);
    }
    var date = Jiffy.parseFromDateTime(month);
    do {
      dates.add(date.dateTime);
      date = date.add(days: 1);
    } while (date.isBefore(monthEnd));

    return dates;
  }

  List<DateTime?> getPaddedDaysEnd(DateTime month) {
    var weekdayAtEnd = endOfMonth(month).dayOfWeek;
    var adjustedWeekday = (6 - weekdayAtEnd);
    List<DateTime?> dates = [];
    for (var i = 0; i <= adjustedWeekday; i++) {
      dates.add(null);
    }
    return dates;
  }

  /// Returns true if the two dates are on the same day
  bool areOnSameDay(DateTime a, DateTime b) {
    var dateA = Jiffy.parseFromDateTime(a);
    var dateB = Jiffy.parseFromDateTime(b);
    return dateA.isSame(dateB, unit: Unit.day);
  }

  /// Returns true if the date is the same day as NOW
  bool isToday(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.isSame(Jiffy.now(), unit: Unit.day);
  }

  /// Returns true if the given date has the same DateComponents as NOW.
  /// Eg. to check if in same year and month
  bool isSameAsNow(DateTime date, List<Unit> Unit) {
    var dateA = dateByUnit(date, Unit);
    var now = dateByUnit(DateTime.now(), Unit);

    return dateA == now;
  }

  String dayString(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.format(pattern: dayFormatter);
  }

  String monthString(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.format(pattern: monthFormatter);
  }

  String monthYearString(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    if (dateA.isSame(Jiffy.now(), unit: Unit.year)) {
      return dateA.format(pattern: monthFormatter);
    } else {
      return dateA.format(pattern: monthYearFormatter);
    }
  }

  List<String> get daysInWeek {
    //TODO: check
    return DateFormat.EEEE(Platform.localeName).dateSymbols.SHORTWEEKDAYS;
  }

  String weekdayAtStartOfMonth(DateTime date) {
    //TODO:
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.startOf(Unit.month).E;
  }

  /// Returns a date representing the start of the day on the supplied date
  Jiffy startOfDay(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.startOf(Unit.day);
  }

  /// Returns a date representing the end of the day on the supplied date
  Jiffy endOfDay(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.endOf(Unit.day);
  }

  /// Returns a date interval representing the start and end of the day on the supplied date
  DateTimeRange wholeDay(DateTime date) {
    return DateTimeRange(start: startOfDay(date).dateTime, end: endOfDay(date).dateTime);
  }

  /// Returns a date representing the start of the first day in the same month as the supplied date
  Jiffy startOfMonth(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.startOf(Unit.month);
  }

  /// Returns a date representing the end of the last day in the same month as the supplied date
  Jiffy endOfMonth(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.endOf(Unit.month);
  }

  /// Returns a date representing the start of the first day in the same year as the supplied date
  Jiffy startOfYear(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.startOf(Unit.year);
  }

  /// Returns a date representing the end of the last day in the same year as the supplied date
  Jiffy endOfYear(DateTime date) {
    var dateA = Jiffy.parseFromDateTime(date);
    return dateA.endOf(Unit.year);
  }

  //Returns a date created from the specified Unit //TODO maybe there is a better solution
  DateTime dateByUnit(DateTime date, List<Unit> Units) {
    //TODO week is not working
    return DateTime(date.year, Units.contains(Unit.month) ? date.month : 1,
        Units.contains(Unit.day) ? date.day : 1, Units.contains(Unit.hour) ? date.hour : 0);
  }
}
