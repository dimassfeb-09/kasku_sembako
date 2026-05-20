import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../bloc/stock_bloc.dart';
import '../bloc/stock_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/adjustment_type_card.dart';

class StockAdjustmentPage extends StatefulWidget {
  final ProductEntity product;
  const StockAdjustmentPage({Key? key, required this.product}) : super(key: key);

  @override
  State<StockAdjustmentPage> createState() => _StockAdjustmentPageState();
}

class _StockAdjustmentPageState extends State<StockAdjustmentPage> {
  final _qtyController = TextEditingController();
  final _notesController = TextEditingController();
  String _adjustmentType = 'IN'; // IN, OUT, ADJUSTMENT_ADD, ADJUSTMENT_SUB

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kuantitas tidak valid')));
      return;
    }

    context.read<StockBloc>().add(
      AdjustStockEvent(
        productId: widget.product.id,
        type: _adjustmentType,
        quantity: qty,
        notes: _notesController.text.trim(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penyesuaian Stok: ${widget.product.name}'),
      ),
      body: BlocListener<StockBloc, StockState>(
        listener: (context, state) {
          if (state is StockOperationSuccess) {
            context.pop(true); // Return true to indicate success and trigger refresh
          } else if (state is StockError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Stok Saat Ini: ${widget.product.stock} ${widget.product.unit}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'Tipe Penyesuaian',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.45,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  AdjustmentTypeCard(
                    value: 'IN',
                    title: 'Stok Masuk',
                    subtitle: 'Pembelian / retur barang',
                    icon: Icons.add_box_rounded,
                    activeColor: AppColors.success,
                    activeBg: AppColors.successLight,
                    selectedValue: _adjustmentType,
                    onChanged: (val) => setState(() => _adjustmentType = val),
                  ),
                  AdjustmentTypeCard(
                    value: 'OUT',
                    title: 'Stok Keluar',
                    subtitle: 'Rusak / kedaluwarsa',
                    icon: Icons.indeterminate_check_box_rounded,
                    activeColor: AppColors.danger,
                    activeBg: AppColors.dangerLight,
                    selectedValue: _adjustmentType,
                    onChanged: (val) => setState(() => _adjustmentType = val),
                  ),
                  AdjustmentTypeCard(
                    value: 'ADJUSTMENT_ADD',
                    title: 'Opname Tambah',
                    subtitle: 'Koreksi stok berlebih',
                    icon: Icons.playlist_add_check_rounded,
                    activeColor: AppColors.info,
                    activeBg: const Color(0xFFEFF6FF),
                    selectedValue: _adjustmentType,
                    onChanged: (val) => setState(() => _adjustmentType = val),
                  ),
                  AdjustmentTypeCard(
                    value: 'ADJUSTMENT_SUB',
                    title: 'Opname Kurang',
                    subtitle: 'Koreksi stok kurang',
                    icon: Icons.playlist_remove_rounded,
                    activeColor: AppColors.warning,
                    activeBg: AppColors.warningLight,
                    selectedValue: _adjustmentType,
                    onChanged: (val) => setState(() => _adjustmentType = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppInput(label: 'Jumlah', controller: _qtyController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              AppInput(label: 'Catatan (Opsional)', controller: _notesController),
              const SizedBox(height: 32),
              BlocBuilder<StockBloc, StockState>(
                builder: (context, state) {
                  return AppButton(
                    text: 'Simpan',
                    isLoading: state is StockLoading,
                    onPressed: _onSave,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

}
