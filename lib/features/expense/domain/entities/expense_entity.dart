class ExpenseEntity {
  final String id;
  final String category;
  final double amount;
  final String? notes;
  final DateTime date;
  final String? receiptPath;

  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.amount,
    this.notes,
    required this.date,
    this.receiptPath,
  });
}
