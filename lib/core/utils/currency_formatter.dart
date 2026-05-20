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

extension NullableRupiahExtension on num? {
  String toRupiah({bool withSymbol = true}) {
    if (this == null) return withSymbol ? 'Rp 0' : '0';
    return this!.toRupiah(withSymbol: withSymbol);
  }
}
