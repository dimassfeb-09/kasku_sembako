class CashSuggestionHelper {
  /// Returns up to 5 recommended cash denominations / payment options for a given total transaction amount.
  static List<double> getSuggestions(double total) {
    if (total <= 0) return [];
    final Set<double> suggestions = {};

    // 1. Uang pas
    suggestions.add(total);

    // 2. Kelipatan Rp 50.000 terdekat ke atas
    final next50k = (total / 50000).ceil() * 50000;
    if (next50k >= total) {
      suggestions.add(next50k.toDouble());
    }

    // 3. Kelipatan Rp 100.000 terdekat ke atas
    final next100k = (total / 100000).ceil() * 100000;
    if (next100k >= total) {
      suggestions.add(next100k.toDouble());
    }

    // 4. Pembayaran pecahan realistis (Hanya berlaku untuk total di bawah Rp 500.000)
    if (total < 500000 && total % 50000 != 0) {
      final base50 = (total / 50000).floor() * 50000;

      // a. base50 + Rp 20.000 (misal total 410k/415k -> bayar 420k)
      if (base50 + 20000 >= total) {
        suggestions.add((base50 + 20000).toDouble());
      }
      // b. base50 + Rp 40.000 (misal total 430k/435k -> bayar 440k)
      if (base50 + 40000 >= total) {
        suggestions.add((base50 + 40000).toDouble());
      }

      // c. Tambahan Rp 10.000 atau Rp 20.000 di atas total agar mendapat kembalian bulat
      final targetPay10kChange = total + 10000;
      if (targetPay10kChange % 20000 == 0 || targetPay10kChange % 50000 == 0) {
        suggestions.add(targetPay10kChange);
      }
      final targetPay20kChange = total + 20000;
      if (targetPay20kChange % 50000 == 0) {
        suggestions.add(targetPay20kChange);
      }
    }

    // 5. Pecahan lembaran uang kertas standar untuk total kecil
    if (total < 50000) {
      final smallDenoms = [5000, 10000, 20000, 50000];
      for (final d in smallDenoms) {
        if (d >= total) {
          suggestions.add(d.toDouble());
        }
      }
    } else if (total < 100000) {
      suggestions.add(100000.toDouble());
    }

    // Urutkan dan ambil maksimal 5 saran terdekat agar rapi
    final sorted = suggestions.toList()..sort();
    return sorted.take(5).toList();
  }
}
