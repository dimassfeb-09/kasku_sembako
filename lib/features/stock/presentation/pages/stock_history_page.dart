import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../bloc/stock_bloc.dart';
import '../bloc/stock_event_state.dart';
import '../../../../core/theme/app_colors.dart';

class StockHistoryPage extends StatefulWidget {
  final ProductEntity product;
  const StockHistoryPage({super.key, required this.product});

  @override
  State<StockHistoryPage> createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<StockBloc>().add(LoadStockHistoryEvent(widget.product.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Stok: ${widget.product.name}')),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockHistoryLoaded) {
            final subState = context.read<SubscriptionCubit>().state;
            final isPro =
                subState is SubscriptionStatusLoaded &&
                subState.status.isEntitled;

            var histories = List.of(state.histories);
            if (!isPro) {
              final oneMonthAgo = DateTime.now().subtract(
                const Duration(days: 30),
              );
              histories = histories
                  .where((h) => h.createdAt.isAfter(oneMonthAgo))
                  .toList();
            }

            if (histories.isEmpty) {
              return const Center(child: Text('Belum ada riwayat stok.'));
            }
            // Sort by createdAt descending
            histories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: histories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final history = histories[index];
                final isAddition =
                    history.type == 'IN' || history.type == 'ADJUSTMENT_ADD';
                final color = isAddition ? AppColors.success : AppColors.danger;
                final sign = isAddition ? '+' : '-';

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: Icon(
                        isAddition ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                      ),
                    ),
                    title: Text(
                      '${history.type} ($sign${history.quantity})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    subtitle: Text(
                      history.notes.isNotEmpty
                          ? history.notes
                          : 'Tanpa catatan',
                    ),
                    trailing: Text(
                      '${history.createdAt.day}/${history.createdAt.month}/${history.createdAt.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            );
          } else if (state is StockError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
