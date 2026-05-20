import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../di/injection.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class WholesaleManagementPage extends StatefulWidget {
  const WholesaleManagementPage({super.key});

  @override
  State<WholesaleManagementPage> createState() =>
      _WholesaleManagementPageState();
}

class _WholesaleManagementPageState extends State<WholesaleManagementPage> {
  final _searchController = TextEditingController();
  final _db = sl<AppDatabase>();
  Map<String, int> _wholesaleTiersCount = {};

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsEvent());
    _loadAllWholesaleTiersCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Menghitung jumlah tier grosir untuk setiap produk secara real-time
  Future<void> _loadAllWholesaleTiersCount() async {
    try {
      final prices = await _db.select(_db.wholesalePrices).get();
      final Map<String, int> counts = {};
      for (var price in prices) {
        counts[price.productId] = (counts[price.productId] ?? 0) + 1;
      }
      if (mounted) {
        setState(() {
          _wholesaleTiersCount = counts;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Kelola Harga Grosir'), elevation: 0),
      body: Column(
        children: [
          // Search Bar Panel
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari produk atau scan barcode...',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Product List
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state is ProductLoaded) {
                  final query = _searchController.text.toLowerCase().trim();
                  final products = state.products
                      .where(
                        (p) =>
                            p.isActive &&
                            (p.name.toLowerCase().contains(query) ||
                                p.barcode.toLowerCase().contains(query)),
                      )
                      .toList();

                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada produk yang cocok.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final tierCount = _wholesaleTiersCount[product.id] ?? 0;

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            vertical: 8,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                product.imagePath != null &&
                                    File(product.imagePath!).existsSync()
                                ? Image.file(
                                    File(product.imagePath!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.primaryLight,
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Eceran: ${(product.sellingPrice as num).toRupiah()} / ${product.unit}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: tierCount > 0
                                      ? AppColors.successLight
                                      : AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tierCount > 0
                                          ? Icons.verified_outlined
                                          : Icons.info_outline,
                                      color: tierCount > 0
                                          ? AppColors.success
                                          : AppColors.warning,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      tierCount > 0
                                          ? '$tierCount Level Grosir'
                                          : 'Belum Ada Grosir',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: tierCount > 0
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          onTap: () async {
                            // Navigasi ke halaman detail set grosir produk
                            await context.push(
                              '/products/wholesale',
                              extra: product,
                            );
                            // Refresh jumlah tier setelah kembali
                            _loadAllWholesaleTiersCount();
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
