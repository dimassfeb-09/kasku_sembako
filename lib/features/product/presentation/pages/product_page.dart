import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/export_service.dart';
import '../../../../shared/widgets/barcode_scanner_sheet.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_list_item.dart';
import '../../../../core/theme/app_colors.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsEvent());
  }

  Future<void> _scanBarcode() async {
    final code = await showBarcodeScanner(context);
    if (code != null && mounted) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductLoaded) {
        final found = state.products.where((p) => p.barcode == code).toList();
        if (found.isNotEmpty && mounted) {
          context.push('/products/edit', extra: found.first);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produk dengan barcode $code tidak ditemukan'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _exportCsv(BuildContext context) {
    final subState = context.read<SubscriptionCubit>().state;
    if (subState is! SubscriptionStatusLoaded || !subState.status.isEntitled) {
      showProUpsell(context, fitur: 'Export data CSV');
      return;
    }
    final state = context.read<ProductBloc>().state;
    if (state is! ProductLoaded || state.products.isEmpty) return;
    sl<ExportService>().exportToCsv(
      headers: [
        'Kode',
        'Nama',
        'Kategori',
        'Harga Beli',
        'Harga Jual',
        'Stok',
        'Satuan',
      ],
      rows: state.products
          .map(
            (p) => [
              p.barcode,
              p.name,
              p.categoryId ?? '',
              p.purchasePrice.toStringAsFixed(0),
              p.sellingPrice.toStringAsFixed(0),
              p.stock.toString(),
              p.unit,
            ],
          )
          .toList(),
      fileName: 'produk.csv',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        title: const Text(
          'Manajemen Produk',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: _scanBarcode,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.table_chart_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () => _exportCsv(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              onPressed: () {
                final bloc = context.read<ProductBloc>();
                context.push('/products/add').then((_) {
                  bloc.add(LoadProductsEvent());
                });
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.successLight,
                elevation: 0,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
            context.read<ProductBloc>().add(LoadProductsEvent());
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.dangerLight,
                elevation: 0,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.danger,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is ProductLoading || current is ProductLoaded,
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          } else if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Belum Ada Produk',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tambahkan produk pertama Anda untuk mulai mengelola stok dan melakukan penjualan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          final bloc = context.read<ProductBloc>();
                          context.push('/products/add').then((_) {
                            bloc.add(LoadProductsEvent());
                          });
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Tambah Produk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final activeProducts = state.products
                .where((p) => p.isActive)
                .toList();
            if (activeProducts.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada produk aktif',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activeProducts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = activeProducts[index];
                return ProductListItem(product: product);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
