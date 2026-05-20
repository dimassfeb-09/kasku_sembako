import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../wholesale_price/domain/entities/wholesale_price_entity.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event_state.dart';

typedef _C = AppColors;

class QtyEditDialog extends StatefulWidget {
  final CartItemEntity item;

  const QtyEditDialog({super.key, required this.item});

  @override
  State<QtyEditDialog> createState() => _QtyEditDialogState();
}

class _QtyEditDialogState extends State<QtyEditDialog> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  late final ProductEntity product;

  @override
  void initState() {
    super.initState();
    product = widget.item.product;
    controller = TextEditingController(text: widget.item.quantity.toString());
    focusNode = FocusNode();
    controller.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_updateState);
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void appendDigit(int digit) {
    final str = controller.text;
    if (str == '0') {
      controller.text = digit.toString();
    } else if (str.length < 4) {
      controller.text = '$str$digit';
    }
  }

  void deleteDigit() {
    final str = controller.text;
    if (str.isNotEmpty) {
      controller.text = str.substring(0, str.length - 1);
      if (controller.text.isEmpty) {
        controller.text = '0';
      }
    }
  }

  void clearDigits() {
    controller.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    final qtyText = controller.text;
    final currentQty = int.tryParse(qtyText) ?? 0;
    final isExceedingStock = currentQty > product.stock;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Ubah Kuantitas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Unified Section Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExceedingStock ? _C.danger : _C.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Info Produk & Stok
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stok tersedia: ${product.stock} ${product.unit}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _C.textSecondary,
                      ),
                    ),
                    // Wholesale prices chips
                    if (widget.item.wholesalePrices.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: widget.item.wholesalePrices.map<Widget>((wp) {
                          final isActive = currentQty >= wp.minQty;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? _C.successLight : _C.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isActive ? _C.success : _C.border,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '≥${wp.minQty}: ${(wp.price as num).toRupiah()}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: isActive ? _C.success : _C.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: _C.border),
                    ),
                    // 2. Row Pengatur Kuantitas (- / Qty / +)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jumlah Beli',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.textSecondary,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (currentQty > 0) {
                                  controller.text = (currentQty - 1).toString();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _C.border),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: _C.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: controller,
                                focusNode: focusNode,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isExceedingStock
                                      ? _C.danger
                                      : _C.primary,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  border: InputBorder.none,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                if (currentQty < product.stock) {
                                  controller.text = (currentQty + 1).toString();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _C.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: _C.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: _C.border),
                    ),
                    // 3. Live Price Info (Harga Satuan & Subtotal)
                    Builder(
                      builder: (context) {
                        double getUnitPriceForQty(int qty) {
                          final wpList = widget.item.wholesalePrices;
                          if (wpList.isEmpty) return product.sellingPrice;
                          final sorted = List<WholesalePriceEntity>.from(wpList)
                            ..sort((a, b) => b.minQty.compareTo(a.minQty));
                          for (var wp in sorted) {
                            if (qty >= wp.minQty) {
                              return wp.price;
                            }
                          }
                          return product.sellingPrice;
                        }

                        final currentPrice = getUnitPriceForQty(currentQty);
                        final subtotal = currentPrice * currentQty;
                        final isWholesaleApplied =
                            currentPrice < product.sellingPrice;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Harga Satuan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _C.textSecondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (isWholesaleApplied) ...[
                                      Text(
                                        (product.sellingPrice as num)
                                            .toRupiah(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: _C.textMuted,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      currentPrice.toRupiah(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isWholesaleApplied
                                            ? _C.success
                                            : _C.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _C.textPrimary,
                                  ),
                                ),
                                Text(
                                  subtotal.toRupiah(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _C.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (isExceedingStock) ...[
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Kuantitas melebihi stok tersedia!',
                    style: TextStyle(
                      color: _C.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Grid Keypad
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  Widget childChild;
                  VoidCallback callback;

                  if (index < 9) {
                    final digit = index + 1;
                    childChild = Text(
                      '$digit',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    );
                    callback = () => appendDigit(digit);
                  } else if (index == 9) {
                    // Clear
                    childChild = const Text(
                      'C',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _C.danger,
                      ),
                    );
                    callback = clearDigits;
                  } else if (index == 10) {
                    // 0
                    childChild = const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    );
                    callback = () => appendDigit(0);
                  } else {
                    // Backspace
                    childChild = const Icon(
                      Icons.backspace_outlined,
                      color: _C.textSecondary,
                      size: 18,
                    );
                    callback = deleteDigit;
                  }

                  return Material(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: callback,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _C.border),
                        ),
                        child: Center(child: childChild),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _C.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: _C.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isExceedingStock
                          ? null
                          : () {
                              if (currentQty <= 0) {
                                context.read<PosBloc>().add(
                                  RemoveFromCartEvent(product),
                                );
                              } else {
                                context.read<PosBloc>().add(
                                  UpdateCartItemQtyEvent(product, currentQty),
                                );
                              }
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: _C.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
