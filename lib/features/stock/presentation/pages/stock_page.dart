import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_event_state.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../widgets/stock_product_list_item.dart';
import '../widgets/stock_filter_chip.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  String _stockFilter = 'ALL'; // ALL, OUT_OF_STOCK, LOW_STOCK

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsEvent());
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Stok'), elevation: 0),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama produk atau scan barcode...',
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
                const SizedBox(height: 10),
                // Stock Status Filter Row
                Row(
                  children: [
                    StockFilterChip(
                      value: 'ALL',
                      label: 'Semua Stok',
                      selectedValue: _stockFilter,
                      onChanged: (val) => setState(() => _stockFilter = val),
                    ),
                    const SizedBox(width: 8),
                    StockFilterChip(
                      value: 'OUT_OF_STOCK',
                      label: 'Stok Habis',
                      selectedValue: _stockFilter,
                      onChanged: (val) => setState(() => _stockFilter = val),
                    ),
                    const SizedBox(width: 8),
                    StockFilterChip(
                      value: 'LOW_STOCK',
                      label: 'Stok Menipis',
                      selectedValue: _stockFilter,
                      onChanged: (val) => setState(() => _stockFilter = val),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, categoryState) {
                    if (categoryState is CategoryLoaded &&
                        categoryState.categories.isNotEmpty) {
                      final categories = categoryState.categories;
                      return SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                            final category = isAll
                                ? null
                                : categories[index - 1];
                            final isSelected = isAll
                                ? _selectedCategoryId == null
                                : _selectedCategoryId == category!.id;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = isAll
                                        ? null
                                        : category!.id;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    isAll ? 'Semua Kategori' : category!.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          // Product List
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              buildWhen: (previous, current) =>
                  current is ProductLoading || current is ProductLoaded,
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state is ProductLoaded) {
                  var filtered = state.products;

                  // Filter by Search Query
                  final query = _searchController.text.trim().toLowerCase();
                  if (query.isNotEmpty) {
                    filtered = filtered.where((p) {
                      return p.name.toLowerCase().contains(query) ||
                          p.barcode.toLowerCase().contains(query);
                    }).toList();
                  }

                  // Filter by Category
                  if (_selectedCategoryId != null) {
                    filtered = filtered.where((p) {
                      return p.categoryId == _selectedCategoryId;
                    }).toList();
                  }

                  // Filter by Stock Status
                  if (_stockFilter == 'OUT_OF_STOCK') {
                    filtered = filtered.where((p) => p.stock <= 0).toList();
                  } else if (_stockFilter == 'LOW_STOCK') {
                    filtered = filtered
                        .where((p) => p.stock > 0 && p.stock <= 5)
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Produk tidak ditemukan',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return StockProductListItem(product: filtered[index]);
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
