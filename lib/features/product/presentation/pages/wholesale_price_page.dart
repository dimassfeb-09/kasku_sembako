import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/wholesale_price_entity.dart';
import '../bloc/wholesale_price_bloc.dart';
import '../bloc/wholesale_price_event_state.dart';
import '../widgets/wholesale_price_list_item.dart';
import '../widgets/wholesale_empty_state.dart';

class WholesalePricePage extends StatefulWidget {
  final ProductEntity product;
  const WholesalePricePage({Key? key, required this.product}) : super(key: key);

  @override
  State<WholesalePricePage> createState() => _WholesalePricePageState();
}

class _WholesalePricePageState extends State<WholesalePricePage> {
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<WholesalePriceBloc>().add(
      LoadWholesalePricesEvent(widget.product.id),
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onAddPrice() {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;

    if (qty <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuantitas dan Harga tidak valid')),
      );
      return;
    }

    if (qty <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kuantitas minimal grosir harus lebih besar dari 1'),
        ),
      );
      return;
    }

    if (price >= widget.product.sellingPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harga grosir harus lebih murah dari harga eceran reguler (${widget.product.sellingPrice.toRupiah()})',
          ),
        ),
      );
      return;
    }

    final entity = WholesalePriceEntity(
      id: const Uuid().v4(),
      productId: widget.product.id,
      minQty: qty,
      price: price,
    );

    context.read<WholesalePriceBloc>().add(AddWholesalePriceEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Pengaturan Harga Grosir'),
        elevation: 0,
      ),
      body: BlocListener<WholesalePriceBloc, WholesalePriceState>(
        listener: (context, state) {
          if (state is WholesalePriceOperationSuccess) {
            _qtyController.clear();
            _priceController.clear();
            context.read<WholesalePriceBloc>().add(
              LoadWholesalePricesEvent(widget.product.id),
            );
          } else if (state is WholesalePriceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            // Product info header card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRODUK UTAMA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Harga Eceran (Retail)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.product.sellingPrice.toRupiah(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 32, width: 1, color: AppColors.primary.withOpacity(0.2)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Stok Saat Ini',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.product.stock} ${widget.product.unit}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Form card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.add_chart_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tambah Tier Grosir',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppInput(
                            label: 'Min. Qty',
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                            hintText: 'Misal: 5',
                            prefixIcon: Icons.shopping_bag_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppInput(
                            label: 'Harga Grosir',
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            hintText: 'Misal: 9500',
                            prefixIcon: Icons.sell_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Harga grosir per unit harus lebih murah dari harga eceran.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<WholesalePriceBloc, WholesalePriceState>(
                      builder: (context, state) {
                        return AppButton(
                          text: 'Simpan Tier Grosir',
                          isLoading: state is WholesalePriceLoading,
                          onPressed: _onAddPrice,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Tier list section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      'Daftar Tier Grosir Aktif',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<WholesalePriceBloc, WholesalePriceState>(
                      builder: (context, state) {
                        if (state is WholesalePriceLoaded &&
                            state.prices.isNotEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${state.prices.length} Tier',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Tier List
            BlocBuilder<WholesalePriceBloc, WholesalePriceState>(
              buildWhen: (previous, current) =>
                  current is WholesalePriceLoading ||
                  current is WholesalePriceLoaded,
              builder: (context, state) {
                if (state is WholesalePriceLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                } else if (state is WholesalePriceLoaded) {
                  if (state.prices.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: WholesaleEmptyState(),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        // Sort prices by minQty ascending so the tiers look like a progress chain
                        final sortedPrices = List.of(state.prices)
                          ..sort((a, b) => a.minQty.compareTo(b.minQty));

                        final price = sortedPrices[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: WholesalePriceListItem(
                            price: price,
                            retailPrice: widget.product.sellingPrice,
                            unit: widget.product.unit,
                          ),
                        );
                      }, childCount: state.prices.length),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

}
