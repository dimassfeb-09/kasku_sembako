import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../user_management/presentation/bloc/permission_cubit.dart';
import '../../../report/presentation/bloc/report_bloc.dart';
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
    context.read<ReportBloc>().add(LoadReportsEvent(_startDate, _endDate));
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
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
    final dateFormat = DateFormat('dd MMM yyyy');
    final permissionState = context.watch<PermissionCubit>().state;
    final checkingPermission =
        permissionState is PermissionLoading ||
        permissionState is PermissionInitial;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi'), elevation: 0),
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
          if (state is ReportLoading || checkingPermission) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ReportLoaded) {
            final transactions = state.transactions;

            return Column(
              children: [
                TransactionHistoryFilterHeader(
                  startDate: _startDate,
                  endDate: _endDate,
                  transactionCount: transactions.length,
                  onTapFilterDate: () => _selectDateRange(context),
                ),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: transactions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Riwayat Transaksi Kosong',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tidak ada transaksi pada periode ini.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final trx = transactions[index];
                            return TransactionHistoryItem(
                              transaction: trx,
                              onTap: () => _showTransactionDetail(context, trx),
                            );
                          },
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
    final permissionState = context.read<PermissionCubit>().state;
    final canVoid =
        permissionState is PermissionLoaded && permissionState.canVoid;

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
          canVoid: canVoid,
          onVoidPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => const VoidConfirmDialog(),
            );
            if (confirm == true) {
              if (context.mounted) {
                Navigator.pop(ctx); // Close sheet
                context.read<ReportBloc>().add(VoidTransactionEvent(trx.id));
              }
            }
          },
        );
      },
    );
  }
}
