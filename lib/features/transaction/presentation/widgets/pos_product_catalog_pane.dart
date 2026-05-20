import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirku_sembako/features/category/domain/entities/category_entity.dart';
import 'package:kasirku_sembako/features/product/presentation/bloc/product_bloc.dart';
import 'package:kasirku_sembako/features/product/presentation/bloc/product_state.dart';
import 'package:kasirku_sembako/features/transaction/presentation/bloc/pos_bloc.dart';
import 'package:kasirku_sembako/features/transaction/presentation/bloc/pos_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import 'product_card.dart';

typedef _C = AppColors;

class PosProductCatalogPane extends StatefulWidget {
  final List<CategoryEntity> categories;

  const PosProductCatalogPane({super.key, required this.categories});

  @override
  State<PosProductCatalogPane> createState() => _PosProductCatalogPaneState();
}

class _PosProductCatalogPaneState extends State<PosProductCatalogPane> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String? name) {
    if (name == null) return Icons.all_inclusive_rounded;
    final lower = name.toLowerCase();
    if (lower.contains('makan') ||
        lower.contains('snack') ||
        lower.contains('roti') ||
        lower.contains('mie')) {
      return Icons.lunch_dining_rounded;
    }
    if (lower.contains('minum') ||
        lower.contains('kopi') ||
        lower.contains('susu') ||
        lower.contains('teh') ||
        lower.contains('jus')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('sembako') ||
        lower.contains('beras') ||
        lower.contains('minyak') ||
        lower.contains('gula') ||
        lower.contains('garam')) {
      return Icons.kitchen_rounded;
    }
    if (lower.contains('sabun') ||
        lower.contains('cuci') ||
        lower.contains('mandi') ||
        lower.contains('shampoo') ||
        lower.contains('odol')) {
      return Icons.clean_hands_rounded;
    }
    if (lower.contains('rokok') || lower.contains('tembakau')) {
      return Icons.smoking_rooms_rounded;
    }
    if (lower.contains('bumbu') || lower.contains('dapur')) {
      return Icons.soup_kitchen_rounded;
    }
    return Icons.label_important_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isSearchFocused = _searchFocusNode.hasFocus;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Cari produk atau scan barcode...',
              hintStyle: const TextStyle(color: _C.textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: _C.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 18,
                        color: _C.textMuted,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: isSearchFocused ? _C.white : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _C.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _C.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _C.primary, width: 1.5),
              ),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
        // Category chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final category = isAll ? null : widget.categories[index - 1];
              final isSelected = isAll
                  ? _selectedCategoryId == null
                  : _selectedCategoryId == category!.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategoryId = isAll ? null : category!.id;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _C.white : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: isSelected ? _C.primary : _C.borderLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(isAll ? null : category!.name),
                          size: 14,
                          color: isSelected ? _C.primary : _C.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAll ? 'Semua' : category!.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected ? _C.primary : _C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Product grid
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: _C.primary),
                );
              }
              if (state is ProductLoaded) {
                final query = _searchController.text.toLowerCase();
                var products = state.products.where((p) => p.isActive).toList();

                if (_selectedCategoryId != null) {
                  products = products
                      .where((p) => p.categoryId == _selectedCategoryId)
                      .toList();
                }
                if (query.isNotEmpty) {
                  products = products
                      .where(
                        (p) =>
                            p.name.toLowerCase().contains(query) ||
                            p.barcode.toLowerCase().contains(query),
                      )
                      .toList();
                }

                if (products.isEmpty) {
                  return const Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 36,
                            color: _C.textMuted,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(
                              color: _C.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final isTablet = MediaQuery.of(context).size.width > 768;
                return BlocBuilder<PosBloc, PosState>(
                  builder: (context, posState) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        childAspectRatio: isTablet ? 0.8 : 0.72,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final cartIdx = posState.cartItems.indexWhere(
                          (item) => item.product.id == product.id,
                        );
                        final isInCart = cartIdx != -1;
                        final currentQty = isInCart
                            ? posState.cartItems[cartIdx].quantity
                            : 0;

                        final availableStock = product.stock - currentQty;
                        final isOutOfStock = product.stock <= 0;
                        final isLowStock =
                            availableStock > 0 && availableStock <= 5;
                        final isMaxStockReached = availableStock <= 0;

                        return ProductCard(
                          product: product,
                          isOutOfStock: isOutOfStock,
                          isLowStock: isLowStock,
                          currentQty: currentQty,
                          availableStock: availableStock,
                          onTap: isMaxStockReached
                              ? null
                              : () => context.read<PosBloc>().add(
                                  AddToCartEvent(product),
                                ),
                          onIncrement: isMaxStockReached
                              ? null
                              : () => context.read<PosBloc>().add(
                                  AddToCartEvent(product),
                                ),
                          onDecrement: !isInCart
                              ? null
                              : () {
                                  if (currentQty > 1) {
                                    context.read<PosBloc>().add(
                                      UpdateCartItemQtyEvent(
                                        product,
                                        currentQty - 1,
                                      ),
                                    );
                                  } else {
                                    context.read<PosBloc>().add(
                                      RemoveFromCartEvent(product),
                                    );
                                  }
                                },
                        );
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
