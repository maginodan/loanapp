import 'package:intl/intl.dart';

String currencyFormatter(double? value) {
  // final val = NumberFormat("#,##0", "en_US");
  final val = NumberFormat("#,##0.00", "en_US");

  return val.format(value).toString();
}
