import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/report_widgets.dart';
import '../widgets/report_loaded_content.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadReport();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadReport() {
    context.read<ReportBloc>().add(LoadReportsEvent(_startDate, _endDate));
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.background,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _animController.forward(from: 0);
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ReportAppBar(
        startDate: _startDate,
        endDate: _endDate,
        onBack: () => Navigator.pop(context),
        onSelectDateRange: () => _selectDateRange(context),
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ReportExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is ReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          // Prevent UI rebuild when only exporting state
          return current is! ReportExporting &&
              current is! ReportExportSuccess &&
              current is! ReportExportError;
        },
        builder: (context, state) {
          if (state is ReportLoading) return const ReportLoadingWidget();
          if (state is ReportError)
            return ReportErrorState(message: state.message);
          if (state is ReportLoaded) {
            return ReportLoadedContent(state: state, fadeAnimation: _fadeAnim);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
