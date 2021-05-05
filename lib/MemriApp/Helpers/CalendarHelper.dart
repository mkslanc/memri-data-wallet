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
    var startDateJiffy = Jiffy(startDate);
    var endDateJiffy = Jiffy(endDate);
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
    } while (date.valueOf() <= lastMonth.valueOf());

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
    } while (date.valueOf() < monthEnd.valueOf());

    return dates;
  }

  /// Get an array of dates representing the start of each day in the specified period with nil values appended to the start in order to make index 0 represent the first day of a week
  /// (useful for padding the start of the month with empty cells in a calendar view)
  List<DateTime?> getPaddedDays(DateTime month) {
    var weekdayAtStart = startOfMonth(month).day;
    var monthEnd = endOfMonth(month);
    var adjustedWeekday = weekdayAtStart;
    List<DateTime?> dates = [];
    for (var i = 1; i < adjustedWeekday; i++) {
      dates.add(null);
    }
    var date = Jiffy(month);
    do {
      dates.add(date.dateTime);
      date = date.add(days: 1);
    } while (date.isBefore(monthEnd));

    return dates;
  }

  List<DateTime?> getPaddedDaysEnd(DateTime month) {
    var weekdayAtEnd = endOfMonth(month).day;
    var adjustedWeekday = (6 - weekdayAtEnd);
    List<DateTime?> dates = [];
    for (var i = 0; i <= adjustedWeekday; i++) {
      dates.add(null);
    }
    return dates;
  }

  /// Returns true if the two dates are on the same day
  bool areOnSameDay(DateTime a, DateTime b) {
    var dateA = Jiffy(a);
    var dateB = Jiffy(b);
    return dateA.isSame(dateB, Units.DAY);
  }

  /// Returns true if the date is the same day as NOW
  bool isToday(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.isSame(Jiffy(), Units.DAY);
  }

  /// Returns true if the given date has the same DateComponents as NOW.
  /// Eg. to check if in same year and month
  bool isSameAsNow(DateTime date, List<Units> units) {
    var dateA = dateByUnits(date, units);
    var now = dateByUnits(DateTime.now(), units);

    return dateA == now;
  }

  String dayString(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.format(dayFormatter);
  }

  String monthString(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.format(monthFormatter);
  }

  String monthYearString(DateTime date) {
    var dateA = Jiffy(date);
    if (dateA.isSame(Jiffy(), Units.YEAR)) {
      return dateA.format(monthFormatter);
    } else {
      return dateA.format(monthYearFormatter);
    }
  }

  List<String> get daysInWeek {
    //TODO: check
    return DateFormat.EEEE(Platform.localeName).dateSymbols.SHORTWEEKDAYS;
  }

  String weekdayAtStartOfMonth(DateTime date) {
    //TODO:
    var dateA = Jiffy(date);
    return dateA.startOf(Units.MONTH).E;
  }

  /// Returns a date representing the start of the day on the supplied date
  Jiffy startOfDay(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.startOf(Units.DAY);
  }

  /// Returns a date representing the end of the day on the supplied date
  Jiffy endOfDay(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.endOf(Units.DAY);
  }

  /// Returns a date interval representing the start and end of the day on the supplied date
  DateTimeRange wholeDay(DateTime date) {
    return DateTimeRange(start: startOfDay(date).dateTime, end: endOfDay(date).dateTime);
  }

  /// Returns a date representing the start of the first day in the same month as the supplied date
  Jiffy startOfMonth(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.startOf(Units.MONTH);
  }

  /// Returns a date representing the end of the last day in the same month as the supplied date
  Jiffy endOfMonth(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.endOf(Units.MONTH);
  }

  /// Returns a date representing the start of the first day in the same year as the supplied date
  Jiffy startOfYear(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.startOf(Units.YEAR);
  }

  /// Returns a date representing the end of the last day in the same year as the supplied date
  Jiffy endOfYear(DateTime date) {
    var dateA = Jiffy(date);
    return dateA.endOf(Units.YEAR);
  }

  //Returns a date created from the specified Units //TODO maybe there is a better solution
  DateTime dateByUnits(DateTime date, List<Units> units) {
    //TODO week is not working
    return DateTime(date.year, units.contains(Units.MONTH) ? date.month : 1,
        units.contains(Units.DAY) ? date.day : 1, units.contains(Units.HOUR) ? date.hour : 0);
  }
}
