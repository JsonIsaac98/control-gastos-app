import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get formattedDate => DateFormat('dd/MM/yyyy').format(this);

  String get formattedDateLong => DateFormat('d \'de\' MMMM \'de\' yyyy', 'es').format(this);

  String get monthYear => DateFormat('MMMM yyyy', 'es').format(this);

  String get dayMonth => DateFormat('d MMM', 'es').format(this);

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);
}

extension DoubleExtensions on double {
  String get toCurrency {
    final formatter = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }
}
