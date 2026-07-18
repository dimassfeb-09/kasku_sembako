import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../report/presentation/bloc/report_bloc.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../report/presentation/bloc/report_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/transaction_detail_bottom_sheet.dart';
import '../widgets/transaction_history_filter_header.dart';
import '../widgets/transaction_history_item.dart';
import '../widgets/void_confirm_dialog.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final subState = context.read<SubscriptionCubit>().state;
    final isPro =
        subState is SubscriptionStatusLoaded && subState.status.isEntitled;
    var start = _startDate;
    if (!isPro) {
      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
      if (start.isBefore(oneMonthAgo)) start = oneMonthAgo;
    }
    context.read<ReportBloc>().add(LoadReportsEvent(start, _endDate));
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final isPro = isProEntitled(context);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: isPro
          ? DateTime(2020)
          : DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ReportLoaded) {
            final transactions = state.transactions;

            return Column(
              children: [
                TransactionHistoryFilterHeader(
                  startDate: _startDate,
                  endDate: _endDate,
                  transactionCount: transactions.length,
                  onTapFilterDate: () => _selectDateRange(context),
                ),
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 32,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada transaksi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Transaksi akan muncul di sini\nsetelah Anda melakukan penjualan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _loadTransactions(),
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final trx = transactions[index];
                              return TransactionHistoryItem(
                                transaction: trx,
                                onTap: () =>
                                    _showTransactionDetail(context, trx),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, TransactionEntity trx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return TransactionDetailBottomSheet(
          transaction: trx,
          canVoid: isProEntitled(context),
          onVoidPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => const VoidConfirmDialog(),
            );
            if (confirm == true) {
              if (context.mounted) {
                Navigator.pop(ctx);
                context.read<ReportBloc>().add(VoidTransactionEvent(trx.id));
              }
            }
          },
        );
      },
    );
  }
}
