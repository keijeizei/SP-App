import 'package:intl/intl.dart';

String intToDate(int value) {
  var date = DateTime.fromMillisecondsSinceEpoch(value);
  var d12 = DateFormat('MMM dd, yyyy').format(date);
  return d12;
}

String intToDateTime(int value) {
  var date = DateTime.fromMillisecondsSinceEpoch(value);
  var d12 = DateFormat('MMM dd, yyyy | hh:mm a').format(date);
  return d12;
}
