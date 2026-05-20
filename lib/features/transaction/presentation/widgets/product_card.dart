import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class ProductCard extends StatefulWidget {
  final dynamic product;
  final bool isOutOfStock;
  final bool isLowStock;
  final int currentQty;
  final int availableStock;
  final VoidCallback? onTap;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const ProductCard({
    super.key,
    required this.product,
    required this.isOutOfStock,
    required this.isLowStock,
    required this.currentQty,
    required this.availableStock,
    this.onTap,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _showPlusOne = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.onTap == null) return;

    // Trigger bouncy scale
    await _animController.forward();
    await _animController.reverse();

    // Trigger "+1" floating animation
    setState(() {
      _showPlusOne = true;
    });

    // Fire actual logic
    widget.onTap!();
  }

  void _handleIncrement() {
    if (widget.onIncrement == null) return;
    setState(() {
      _showPlusOne = true;
    });
    widget.onIncrement!();
  }

  void _handleDecrement() {
    if (widget.onDecrement == null) return;
    widget.onDecrement!();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    return ScaleTransition(
      scale: scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: widget.isOutOfStock ? PosColors.surface : PosColors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: PosColors.border, width: 1),
            ),
            child: InkWell(
              onTap: widget.isOutOfStock
                  ? null
                  : (widget.currentQty > 0 ? null : _handleTap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: Stack(
                      children: [
                        widget.product.imagePath != null &&
                                File(widget.product.imagePath!).existsSync()
                            ? Image.file(
                                File(widget.product.imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Container(
                                color: PosColors.primaryLight,
                                width: double.infinity,
                                height: double.infinity,
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: PosColors.primary,
                                  size: 28,
                                ),
                              ),
                        Positioned(
                          left: 6,
                          top: 6,
                          child: StockBadge(
                            isOutOfStock: widget.availableStock <= 0,
                            isLowStock: widget.isLowStock,
                            stock: widget.availableStock,
                            unit: widget.product.unit,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.2,
                            color: widget.isOutOfStock
                                ? PosColors.textMuted
                                : PosColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (widget.product.sellingPrice as num).toRupiah(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: widget.isOutOfStock
                                ? PosColors.textMuted
                                : PosColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: widget.isOutOfStock
                        ? Container(
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: PosColors.dangerLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: PosColors.danger.withOpacity(0.2),
                              ),
                            ),
                            child: const Text(
                              'Stok Habis',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: PosColors.danger,
                              ),
                            ),
                          )
                        : widget.currentQty > 0
                            ? Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  color: PosColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: PosColors.primary.withOpacity(0.15),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: widget.onDecrement == null
                                            ? null
                                            : _handleDecrement,
                                        borderRadius: const BorderRadius.horizontal(
                                          left: Radius.circular(8),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.remove_rounded,
                                            size: 18,
                                            color: widget.onDecrement == null
                                                ? PosColors.textMuted
                                                : PosColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${widget.currentQty}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                            color: PosColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: widget.onIncrement == null
                                            ? null
                                            : _handleIncrement,
                                        borderRadius: const BorderRadius.horizontal(
                                          right: Radius.circular(8),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 18,
                                            color: widget.onIncrement == null
                                                ? PosColors.textMuted
                                                : PosColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: _handleTap,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: PosColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: PosColors.primary.withOpacity(0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tambah',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
          if (_showPlusOne)
            Positioned(
              right: 8,
              top: -6,
              child: FloatingPlusOne(
                onFinished: () {
                  setState(() {
                    _showPlusOne = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

class FloatingPlusOne extends StatefulWidget {
  final VoidCallback onFinished;

  const FloatingPlusOne({super.key, required this.onFinished});

  @override
  State<FloatingPlusOne> createState() => _FloatingPlusOneState();
}

class _FloatingPlusOneState extends State<FloatingPlusOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<double> _yAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_controller);

    _yAnim = Tween<double>(
      begin: 0.0,
      end: -35.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yAnim.value),
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: PosColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: PosColors.primary.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '+1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StockBadge extends StatelessWidget {
  final bool isOutOfStock;
  final bool isLowStock;
  final int stock;
  final String unit;

  const StockBadge({
    super.key,
    required this.isOutOfStock,
    required this.isLowStock,
    required this.stock,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (isOutOfStock) {
      bg = PosColors.dangerLight;
      fg = PosColors.danger;
      icon = Icons.cancel_outlined;
      label = 'Stok Habis';
    } else if (isLowStock) {
      bg = PosColors.warningLight;
      fg = PosColors.warning;
      icon = Icons.warning_amber_rounded;
      label = 'Stok: $stock $unit';
    } else {
      bg = PosColors.successLight;
      fg = PosColors.success;
      icon = Icons.check_circle_outline_rounded;
      label = 'Stok: $stock $unit';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
