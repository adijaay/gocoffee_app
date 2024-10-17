import 'package:intl/intl.dart';

String formatDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  DateFormat dateFormat =
      DateFormat('dd MMMM'); // Format to display day and month
  return dateFormat.format(dateTime);
}

String formatDate(DateTime dateString) {
  String dateFormat =
      DateFormat('dd MMMM').format(dateString); // Format to display day and month
  return dateFormat;
}