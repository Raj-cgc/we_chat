import 'package:flutter/material.dart';

//for getting formatted time from millisecondsSinceEpochs / microsecondsSinceEpochs String
class MyDateUtil {
  // Utility method to safely parse timestamp from epoch String
  static DateTime _getDateTime(String time) {
    final int value = int.tryParse(time) ?? 0;
    if (value <= 0) return DateTime.now();

    // If timestamp is in microseconds (16+ digits)
    if (value > 100000000000000) {
      return DateTime.fromMicrosecondsSinceEpoch(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static String getFormattedTime({
    required BuildContext context,
    required String time,
  }) {
    final date = _getDateTime(time);
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getMessageTime({
    required BuildContext context,
    required String time,
  }) {
    final DateTime sent = _getDateTime(time);
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formattedTime;
    }

    return now.year == sent.year
        ? '$formattedTime - ${sent.day} ${_getMonthName(sent)}'
        : '$formattedTime - ${sent.day} ${_getMonthName(sent)} ${sent.year}';
  }

  //get last msg time to store in chat user card
  static String getLastMessageTime({
    required BuildContext context,
    required String time,
    bool showYear = false,
  }) {
    final DateTime sent = _getDateTime(time);
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    } else {
      return showYear
          ? '${sent.day} ${_getMonthName(sent)} ${sent.year}'
          : '${sent.day} ${_getMonthName(sent)}';
    }
  }

  //get formatted last active time of user in chat screen
  static String getLastActiveTime({
    required BuildContext context,
    required String lastActive,
  }) {
    final int i = int.tryParse(lastActive) ?? -1;

    //if time is not available then return below statement
    if (i == -1) return 'Last seen not available';

    DateTime time = _getDateTime(lastActive);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Last seen today at $formattedTime';
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (time.day == yesterday.day &&
        time.month == yesterday.month &&
        time.year == yesterday.year) {
      return 'Last seen yesterday at $formattedTime';
    }

    String month = _getMonthName(time);

    return 'Last seen on ${time.day} $month on $formattedTime';
  }

  //get month name from month number
  static String _getMonthName(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return 'NA';
    }
  }
}
