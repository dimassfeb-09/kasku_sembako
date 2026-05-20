import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/expense_widgets.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage>
    with SingleTickerProviderStateMixin {
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Design tokens (Light Mode - Shared with Core Design System) ──
  static const _bg = AppColors.background;
  static const _surface = AppColors.surface;
  static const _accentRed = AppColors.error;
  static const _textPrimary = AppColors.textPrimary;
  static const _textSecondary = AppColors.textSecondary;

  // Preset kategori cepat
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
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    context.read<ExpenseBloc>().add(
      LoadExpensesEvent(startDate: start, endDate: end),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
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
                backgroundColor: _accentRed,
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
          _animController.forward(from: 0);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<void> _deleteExpense(ExpenseEntity exp) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: _accentRed, size: 20),
            SizedBox(width: 8),
            Text(
              'Hapus Pengeluaran',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Hapus pengeluaran "${exp.category}" senilai ${exp.amount.toRupiah()}?',
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal', style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<ExpenseBloc>().add(DeleteExpenseEvent(exp.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: ExpenseAppBar(onBack: () => Navigator.pop(context)),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExpenseLoaded) {
            final totalAll = state.expenses.fold(
              0.0,
              (sum, e) => sum + e.amount,
            );
            final grouped = state.groupedByDate;

            return FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  ExpenseSummarySection(
                    totalAll: totalAll,
                    totalToday: state.totalToday,
                    totalThisMonth: state.totalThisMonth,
                    itemCount: state.expenses.length,
                  ),
                  const SizedBox(height: 4),
                  ExpenseListHeader(groupedDays: grouped.length),
                  Expanded(
                    child: state.expenses.isEmpty
                        ? const ExpenseEmptyState()
                        : ExpenseGroupedList(
                            grouped: grouped,
                            onDelete: _deleteExpense,
                          ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
