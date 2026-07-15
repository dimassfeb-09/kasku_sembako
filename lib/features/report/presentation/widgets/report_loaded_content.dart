import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event_state.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';
import 'report_summary_section.dart';
import 'report_transaction_list.dart';

class ReportLoadedContent extends StatelessWidget {
  final ReportLoaded state;
  final Animation<double> fadeAnimation;

  const ReportLoadedContent({
    super.key,
    required this.state,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        children: [
          ReportSummarySection(
            totalOmset: state.totalOmset,
            totalHpp: state.totalHpp,
            totalProfit: state.totalProfit,
            totalTrx: state.transactions.length - state.voidCount,
            voidCount: state.voidCount,
          ),
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
          ),
          Expanded(
            child: state.transactions.isEmpty
                ? const ReportEmptyState()
                : ReportTransactionList(
                    transactions: state.transactions,
                    onVoid: (id) => context.read<ReportBloc>().add(
                      VoidTransactionEvent(id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
