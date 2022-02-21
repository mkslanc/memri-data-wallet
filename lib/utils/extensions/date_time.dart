import 'package:intl/intl.dart';

extension FormattedDate on DateTime {
  static DateTime get oneWeekAgo {
    return DateTime.now().subtract(Duration(days: 7));
  }

  int? get timeDeltaMilliseconds {
    return this.isAtSameMomentAs(DateTime.now())
        ? null
        : this.difference(DateTime.now()).inMilliseconds;
  }

  String get timeDelta {
    var duration = Duration(milliseconds: (timeDeltaMilliseconds?.abs() ?? 0));

    //TODO replace with normal localization
    var durationTypes = ["month", "day", "hour", "minute", "second"];

    return () {
      var durationInt = 0;
      for (var durationType in durationTypes) {
        switch (durationType) {
          case "month":
            durationInt = (duration.inDays / 30).floor();
            break;
          case "day":
            durationInt = duration.inDays;
            break;
          case "hour":
            durationInt = duration.inHours;
            break;
          case "minute":
            durationInt = duration.inMinutes;
            break;
          case "second":
            durationInt = duration.inSeconds;
            break;
        }
        if (durationInt > 0) {
          return "${durationInt.toString()} $durationType${(durationInt > 1) ? "s" : ""}";
        }
      }
      return "";
    }();
  }

  String? get timestampString {
    //TODO: return formatted string like "1 days 2 hours ago" https://github.com/dart-lang/intl/issues/52
    return timeDelta + ' ago';
  }

  String formatted({String dateFormat = "yyyy/MM/dd HH:mm"}) {
    // Compare against 36 hours ago
    if (DateTime.now().subtract(Duration(hours: 36)).millisecondsSinceEpoch >
        this.millisecondsSinceEpoch) {
      var dateFormatter = DateFormat(dateFormat, "en_US");
      return dateFormatter.format(this);
    } else {
      return timestampString ?? "";
    }
  }
}
