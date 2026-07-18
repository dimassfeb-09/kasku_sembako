import 'package:intl/intl.dart';

extension RupiahExtension on num {
  String toRupiah({bool withSymbol = true}) {
    final format = NumberFormat.currency(
      locale: 'id',
      symbol: withSymbol ? 'Rp ' : '',
      decimalDigits: 0,
    );
    return format.format(this);
  }
}
