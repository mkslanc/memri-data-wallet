import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

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
    var duration = Duration(milliseconds: (this.timeDeltaMilliseconds?.abs() ?? 0));
    return duration.toString();
  }

  String? get timestampString {
    var timeInt = timeDeltaMilliseconds;
    if (timeInt == null) {
      return null;
    }
    timeInt = timeInt.abs();

    //TODO: return formatted string like "1 days 2 hours ago" https://github.com/dart-lang/intl/issues/52
    return Jiffy.unix(timeInt).format();
  }

  String formatted({String dateFormat = "yyyy/MM/dd HH:mm"}) {
    // Compare against 36 hours ago
    if (this.subtract(Duration(hours: 36)).millisecondsSinceEpoch < 0) {
      var dateFormatter = DateFormat(dateFormat, "en_US");
      return dateFormatter.format(this);
    } else {
      return timestampString ?? "";
    }
  }
}
