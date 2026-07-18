import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event_state.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';
import 'report_chart_section.dart';
import 'report_summary_section.dart';
import 'report_transaction_detail_sheet.dart';
import 'report_transaction_list.dart';

class ReportLoadedContent extends StatelessWidget {
  final ReportLoaded state;

  const ReportLoadedContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final subState = context.read<SubscriptionCubit>().state;
    final isPro =
        subState is SubscriptionStatusLoaded && subState.status.isEntitled;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              ReportSummarySection(
                totalOmset: state.totalOmset,
                totalHpp: state.totalHpp,
                totalProfit: state.totalProfit,
                totalTrx: state.transactions.length - state.voidCount,
                voidCount: state.voidCount,
              ),
              ReportChartSection(
                transactions: state.transactions,
                startDate: state.startDate,
                endDate: state.endDate,
                isPro: isPro,
              ),
              if (state.transactions.isNotEmpty)
                ReportListHeader(
                  length: state.transactions.length,
                  onExportPdf: () {
                    if (!isProEntitled(context)) {
                      showProUpsell(context, fitur: 'Export laporan PDF');
                      return;
                    }
                    context.read<ReportBloc>().add(ExportPdfEvent());
                  },
                  onExportExcel: () {
                    if (!isProEntitled(context)) {
                      showProUpsell(context, fitur: 'Export laporan Excel');
                      return;
                    }
                    context.read<ReportBloc>().add(ExportExcelEvent());
                  },
                  onExportCsv: () {
                    if (!isProEntitled(context)) {
                      showProUpsell(context, fitur: 'Export data CSV');
                      return;
                    }
                    context.read<ReportBloc>().add(ExportCsvEvent());
                  },
                ),
            ],
          ),
        ),
        if (state.transactions.isEmpty)
          const SliverFillRemaining(child: ReportEmptyState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final trx = state.transactions[index];
              return ReportTransactionTile(
                trx: trx,
                onTap: () {
                  final isVoided = trx.status == 'VOID';
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => ReportTransactionDetailSheet(
                      trx: trx,
                      isVoided: isVoided,
                      onVoid: () {
                        Navigator.pop(ctx);
                        if (!isProEntitled(context)) {
                          showProUpsell(context, fitur: 'Void transaksi');
                          return;
                        }
                        context.read<ReportBloc>().add(
                          VoidTransactionEvent(trx.id),
                        );
                      },
                    ),
                  );
                },
              );
            }, childCount: state.transactions.length),
          ),
      ],
    );
  }
}
