import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';

typedef _C = AppColors;

class ReportChartSection extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPro;

  const ReportChartSection({
    super.key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    final valid = transactions.where((t) => t.status != 'VOID').toList();
    if (valid.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        _DailySalesCard(valid, startDate, endDate),
        if (isPro) ...[
          const SizedBox(height: 8),
          _PaymentMethodCard(valid),
          const SizedBox(height: 8),
          _TopProductsCard(valid),
          const SizedBox(height: 8),
          _ProfitTrendCard(valid, startDate, endDate),
        ],
      ],
    );
  }
}

// ─── Daily Sales Bar Chart ────────────────────────────────────────────────────

class _DailySalesCard extends StatelessWidget {
  final List<TransactionEntity> valid;
  final DateTime startDate, endDate;
  const _DailySalesCard(this.valid, this.startDate, this.endDate);

  @override
  Widget build(BuildContext context) {
    final daily = _groupByDay(valid, startDate, endDate);
    if (daily.isEmpty) return const SizedBox.shrink();
    final maxY = daily.map((d) => d.$2).reduce((a, b) => a > b ? a : b) * 1.2;

    return _chartCard(
      icon: Icons.bar_chart_rounded,
      title: 'Penjualan Harian',
      subtitle:
          '${DateFormat('dd MMM').format(startDate)} — ${DateFormat('dd MMM yyyy').format(endDate)}',
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (g, i, r, ri) {
                final d = daily[i];
                return BarTooltipItem(
                  '${DateFormat('dd MMM').format(d.$1)}\n${d.$2.toRupiah()}',
                  const TextStyle(
                    color: _C.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (v, _) => v == 0
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          NumberFormat.compact(locale: 'id').format(v),
                          style: const TextStyle(
                            fontSize: 9,
                            color: _C.textMuted,
                          ),
                        ),
                      ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= daily.length) {
                    return const SizedBox.shrink();
                  }
                  final show = daily.length > 7
                      ? i % (daily.length ~/ 4 + 1) == 0
                      : true;
                  if (!show) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('dd').format(daily[i].$1),
                      style: const TextStyle(fontSize: 9, color: _C.textMuted),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: _C.borderLight, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: daily
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.$2,
                      color: _C.primary,
                      width: daily.length > 7 ? 8 : 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  List<(DateTime, double)> _groupByDay(
    List<TransactionEntity> tx,
    DateTime start,
    DateTime end,
  ) {
    final map = <DateTime, double>{};
    for (final t in tx) {
      final day = DateTime(
        t.createdAt.year,
        t.createdAt.month,
        t.createdAt.day,
      );
      map[day] = (map[day] ?? 0) + t.totalAmount;
    }
    final result = <(DateTime, double)>[];
    var cur = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cur.isAfter(last)) {
      result.add((cur, map[cur] ?? 0));
      cur = cur.add(const Duration(days: 1));
    }
    return result;
  }
}

// ─── Payment Method Pie Chart ─────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
  final List<TransactionEntity> valid;
  const _PaymentMethodCard(this.valid);

  @override
  Widget build(BuildContext context) {
    final map = <String, double>{};
    for (final t in valid) {
      map[t.paymentMethod] = (map[t.paymentMethod] ?? 0) + t.totalAmount;
    }
    if (map.isEmpty) return const SizedBox.shrink();

    final colors = [
      const Color(0xFF0D9488),
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];
    final entries = map.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return _chartCard(
      icon: Icons.pie_chart_rounded,
      title: 'Metode Pembayaran',
      subtitle: 'Distribusi total omset',
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: entries
                    .asMap()
                    .entries
                    .map(
                      (e) => PieChartSectionData(
                        value: e.value.value,
                        color: colors[e.key % colors.length],
                        radius: 50,
                        title:
                            '${(e.value.value / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors[e.key % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.value.key,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.value.value.toRupiah(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: _C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Top 5 Products Bar Chart ─────────────────────────────────────────────────

class _TopProductsCard extends StatelessWidget {
  final List<TransactionEntity> valid;
  const _TopProductsCard(this.valid);

  @override
  Widget build(BuildContext context) {
    final map = <String, double>{};
    for (final t in valid) {
      for (final item in t.items) {
        map[item.productName] = (map[item.productName] ?? 0) + item.subtotal;
      }
    }
    if (map.isEmpty) return const SizedBox.shrink();

    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    final maxVal = top5.first.value;

    return _chartCard(
      icon: Icons.star_rounded,
      title: 'Top 5 Produk',
      subtitle: 'Berdasarkan total penjualan',
      height: 220,
      child: Column(
        children: top5
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${e.key + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _C.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        e.value.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Stack(
                          children: [
                            Container(height: 14, color: _C.borderLight),
                            FractionallySizedBox(
                              widthFactor: e.value.value / maxVal,
                              child: Container(height: 14, color: _C.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: Text(
                        e.value.value.toRupiah(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Profit Trend Line Chart ──────────────────────────────────────────────────

class _ProfitTrendCard extends StatelessWidget {
  final List<TransactionEntity> valid;
  final DateTime startDate, endDate;
  const _ProfitTrendCard(this.valid, this.startDate, this.endDate);

  @override
  Widget build(BuildContext context) {
    final daily = _groupDailyProfit(valid, startDate, endDate);
    if (daily.isEmpty) return const SizedBox.shrink();

    final spots = daily
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.$2))
        .toList();
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3;
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final showMin = minY < 0;

    return _chartCard(
      icon: Icons.trending_up_rounded,
      title: 'Tren Laba',
      subtitle:
          '${DateFormat('dd MMM').format(startDate)} — ${DateFormat('dd MMM yyyy').format(endDate)}',
      height: 180,
      child: LineChart(
        LineChartData(
          minY: showMin ? minY * 1.3 : 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      '${DateFormat('dd MMM').format(daily[s.spotIndex].$1)}\n${s.y.toRupiah()}',
                      const TextStyle(
                        color: _C.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (v, _) => v == 0
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          NumberFormat.compact(locale: 'id').format(v),
                          style: const TextStyle(
                            fontSize: 9,
                            color: _C.textMuted,
                          ),
                        ),
                      ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= daily.length) {
                    return const SizedBox.shrink();
                  }
                  final show = daily.length > 7
                      ? i % (daily.length ~/ 4 + 1) == 0
                      : true;
                  if (!show) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('dd').format(daily[i].$1),
                      style: const TextStyle(fontSize: 9, color: _C.textMuted),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - (showMin ? minY * 1.3 : 0)) / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: _C.borderLight, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _C.primary,
              barWidth: 2,
              dotData: FlDotData(show: daily.length <= 14),
              belowBarData: BarAreaData(
                show: true,
                color: _C.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<(DateTime, double)> _groupDailyProfit(
    List<TransactionEntity> tx,
    DateTime start,
    DateTime end,
  ) {
    final map = <DateTime, double>{};
    for (final t in tx) {
      final day = DateTime(
        t.createdAt.year,
        t.createdAt.month,
        t.createdAt.day,
      );
      final hpp = t.items.fold(0.0, (s, i) => s + (i.purchasePrice * i.qty));
      map[day] = (map[day] ?? 0) + (t.totalAmount - hpp);
    }
    final result = <(DateTime, double)>[];
    var cur = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cur.isAfter(last)) {
      result.add((cur, map[cur] ?? 0));
      cur = cur.add(const Duration(days: 1));
    }
    return result;
  }
}

// ─── Shared Chart Card Wrapper ────────────────────────────────────────────────

Widget _chartCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required double height,
  required Widget child,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _C.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: _C.textMuted),
          ),
          const SizedBox(height: 16),
          SizedBox(height: height, child: child),
        ],
      ),
    ),
  );
}
