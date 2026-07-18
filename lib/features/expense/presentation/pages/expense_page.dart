import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/expense_app_bar.dart';
import '../widgets/expense_list_section.dart';
import '../widgets/expense_summary_section.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  static const _quickCategories = [
    ('Listrik', Icons.bolt_rounded),
    ('Air', Icons.water_drop_rounded),
    ('Gaji', Icons.people_rounded),
    ('Sewa', Icons.home_rounded),
    ('Transport', Icons.local_shipping_rounded),
    ('Lainnya', Icons.more_horiz_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadExpenses() {
    context.read<ExpenseBloc>().add(
      LoadExpensesEvent(startDate: _startDate, endDate: _endDate),
    );
  }

  Future<void> _selectDateRange() async {
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
      _loadExpenses();
    }
  }

  Future<void> _showAddExpenseSheet() async {
    _categoryController.clear();
    _amountController.clear();
    _notesController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddExpenseSheet(
        categoryController: _categoryController,
        amountController: _amountController,
        notesController: _notesController,
        quickCategories: _quickCategories,
        onSave: () async {
          final cat = _categoryController.text.trim();
          final amt =
              double.tryParse(
                _amountController.text.replaceAll('.', '').replaceAll(',', ''),
              ) ??
              0.0;
          final notes = _notesController.text.trim();

          if (cat.isEmpty || amt <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                content: const Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Kategori & jumlah harus diisi!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
            return;
          }

          final newExpense = ExpenseEntity(
            id: const Uuid().v4(),
            category: cat,
            amount: amt,
            notes: notes.isNotEmpty ? notes : null,
            date: DateTime.now(),
          );

          context.read<ExpenseBloc>().add(AddExpenseEvent(newExpense));
          if (ctx.mounted) Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<void> _deleteExpense(ExpenseEntity exp) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hapus Catatan Pengeluaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hapus "${exp.category}" senilai ${exp.amount.toRupiah()}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true && mounted) {
      context.read<ExpenseBloc>().add(DeleteExpenseEvent(exp.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ExpenseAppBar(
        onBack: () => Navigator.pop(context),
        startDate: _startDate,
        endDate: _endDate,
        onSelectDateRange: _selectDateRange,
      ),
      floatingActionButton: ExpenseFAB(onTap: _showAddExpenseSheet),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpenseLoading || state is ExpenseInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ExpenseLoaded) {
            final totalAll = state.expenses.fold(
              0.0,
              (sum, e) => sum + e.amount,
            );
            return Column(
              children: [
                ExpenseSummarySection(
                  totalAll: totalAll,
                  totalToday: state.totalToday,
                  totalThisMonth: state.totalThisMonth,
                  itemCount: state.expenses.length,
                ),
                Expanded(
                  child: state.expenses.isEmpty
                      ? const ExpenseEmptyState()
                      : ExpenseGroupedList(
                          grouped: state.groupedByDate,
                          onDelete: _deleteExpense,
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
}
