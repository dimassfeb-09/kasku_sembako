import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirku_sembako/features/category/domain/entities/category_entity.dart';
import 'package:kasirku_sembako/features/product/presentation/bloc/product_bloc.dart';
import 'package:kasirku_sembako/features/product/presentation/bloc/product_state.dart';
import 'package:kasirku_sembako/features/transaction/presentation/bloc/pos_bloc.dart';
import 'package:kasirku_sembako/features/transaction/presentation/bloc/pos_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/barcode_scanner_sheet.dart';
import 'product_card.dart';

typedef _C = AppColors;

String _productInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.length >= 2
      ? name.substring(0, 2).toUpperCase()
      : name.toUpperCase();
}

Color _productColor(String name) {
  const colors = [
    Color(0xFF0D9488),
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
  ];
  return colors[name.hashCode % colors.length];
}

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
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    setState(() {});
  }

  Future<void> _scanBarcode() async {
    final barcode = await showBarcodeScanner(context);
    if (barcode != null && mounted) {
      _searchController.text = barcode;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: barcode.length),
      );
      setState(() {});
    }
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

  Widget _buildItem(
    dynamic product,
    dynamic productPos, {
    required bool isGrid,
  }) {
    final inCart = productPos != null;
    final currentQty = inCart ? productPos.quantity : 0;
    final isUntracked = product.trackStock == false;
    final availableStock = isUntracked ? 999999 : product.stock - currentQty;
    final isOutOfStock = !isUntracked && product.stock <= 0;
    final isLowStock =
        !isUntracked && availableStock > 0 && availableStock <= 5;
    final isMaxed = !isUntracked && availableStock <= 0;

    final addToCart = isMaxed
        ? null
        : () => context.read<PosBloc>().add(AddToCartEvent(product));

    if (isGrid) {
      return ProductCard(
        product: product,
        isOutOfStock: isOutOfStock,
        isLowStock: isLowStock,
        currentQty: currentQty,
        availableStock: availableStock,
        onTap: addToCart,
        onIncrement: addToCart,
      );
    }

    return _ProductListItem(
      product: product,
      isOutOfStock: isOutOfStock,
      isLowStock: isLowStock,
      currentQty: currentQty,
      availableStock: availableStock,
      onTap: addToCart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearchFocused = _searchFocusNode.hasFocus;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: const TextStyle(
                        color: _C.textMuted,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _C.textMuted,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 20,
                              color: _C.textSecondary,
                            ),
                            onPressed: _scanBarcode,
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                size: 18,
                                color: _C.textMuted,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                      filled: true,
                      fillColor: isSearchFocused
                          ? _C.white
                          : const Color(0xFFF8FAFC),
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
                        borderSide: const BorderSide(
                          color: _C.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border),
                  ),
                  child: Row(
                    children: [
                      _ViewToggleButton(
                        icon: Icons.grid_view_rounded,
                        isActive: _isGridView,
                        onTap: () => setState(() {
                          _isGridView = true;
                        }),
                      ),
                      Container(width: 1, color: _C.border),
                      _ViewToggleButton(
                        icon: Icons.list_rounded,
                        isActive: !_isGridView,
                        onTap: () => setState(() {
                          _isGridView = false;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                                  color: Colors.black.withValues(alpha: 0.05),
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
                  var products = state.products
                      .where((p) => p.isActive)
                      .toList();

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
                    );
                  }

                  return BlocBuilder<PosBloc, PosState>(
                    builder: (context, posState) {
                      if (_isGridView) {
                        final isTablet =
                            MediaQuery.of(context).size.width > 768;
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTablet ? 3 : 2,
                                childAspectRatio: isTablet ? 0.9 : 0.85,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: products.length,
                          itemBuilder: (_, i) => _buildItem(
                            products[i],
                            _findInCart(posState, products[i]),
                            isGrid: true,
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: products.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _buildItem(
                            products[i],
                            _findInCart(posState, products[i]),
                            isGrid: false,
                          ),
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

  dynamic _findInCart(PosState posState, dynamic product) {
    final idx = posState.cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    return idx != -1 ? posState.cartItems[idx] : null;
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? _C.primaryLight : Colors.transparent,
          borderRadius: isActive ? BorderRadius.circular(12) : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? _C.primary : _C.textMuted,
        ),
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final dynamic product;
  final bool isOutOfStock;
  final bool isLowStock;
  final int currentQty;
  final int availableStock;
  final VoidCallback? onTap;

  const _ProductListItem({
    required this.product,
    required this.isOutOfStock,
    required this.isLowStock,
    required this.currentQty,
    required this.availableStock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        product.imagePath != null && File(product.imagePath!).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: hasImage
                        ? Image.file(
                            File(product.imagePath!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: _productColor(
                              product.name as String,
                            ).withValues(alpha: 0.12),
                            alignment: Alignment.center,
                            child: Text(
                              _productInitials(product.name as String),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _productColor(product.name as String),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isOutOfStock ? _C.textMuted : _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (product.sellingPrice as num).toRupiah(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isOutOfStock ? _C.textMuted : _C.primary,
                              ),
                            ),
                          ),
                          _buildStockLabel(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockLabel() {
    if (isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _C.dangerLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _C.danger.withValues(alpha: 0.2)),
        ),
        child: const Text(
          'Habis',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: _C.danger,
          ),
        ),
      );
    }
    if (availableStock >= 999) {
      return Icon(Icons.all_inclusive, size: 16, color: _C.textMuted);
    }
    if (isLowStock) {
      return Text(
        'Sisa $availableStock',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _C.warning,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
