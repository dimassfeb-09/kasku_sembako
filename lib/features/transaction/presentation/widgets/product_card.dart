import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.length >= 2
      ? name.substring(0, 2).toUpperCase()
      : name.toUpperCase();
}

Color _cardColor(String name) {
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

class ProductCard extends StatefulWidget {
  final dynamic product;
  final bool isOutOfStock;
  final bool isLowStock;
  final int currentQty;
  final int availableStock;
  final VoidCallback? onTap;
  final VoidCallback? onIncrement;

  const ProductCard({
    super.key,
    required this.product,
    required this.isOutOfStock,
    required this.isLowStock,
    required this.currentQty,
    required this.availableStock,
    this.onTap,
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
    final cb = widget.currentQty > 0 ? widget.onIncrement : widget.onTap;
    if (cb == null) return;
    await _animController.forward();
    await _animController.reverse();
    setState(() {
      _showPlusOne = true;
    });
    cb();
  }

  bool get _hasImage =>
      widget.product.imagePath != null &&
      File(widget.product.imagePath!).existsSync();

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
          Container(
            decoration: BoxDecoration(
              color: widget.isOutOfStock
                  ? const Color(0xFFF8FAFC)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isOutOfStock
                    ? Colors.grey.shade200
                    : PosColors.borderLight,
                width: 1,
              ),
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
                onTap: widget.isOutOfStock ? null : _handleTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Stack(
                        children: [
                          if (_hasImage)
                            Image.file(
                              File(widget.product.imagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          else
                            Container(
                              color: _cardColor(
                                widget.product.name as String,
                              ).withValues(alpha: 0.1),
                              alignment: Alignment.center,
                              child: Text(
                                _initials(widget.product.name as String),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: _cardColor(
                                    widget.product.name as String,
                                  ).withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 6,
                            top: 6,
                            child: _StockBadge(
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
                      padding: const EdgeInsets.all(10),
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
                  ],
                ),
              ),
            ),
          ),
          if (_showPlusOne)
            Positioned(
              right: 8,
              top: -6,
              child: _FloatingPlusOne(
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

class _FloatingPlusOne extends StatefulWidget {
  final VoidCallback onFinished;
  const _FloatingPlusOne({required this.onFinished});
  @override
  State<_FloatingPlusOne> createState() => _FloatingPlusOneState();
}

class _FloatingPlusOneState extends State<_FloatingPlusOne>
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

class _StockBadge extends StatelessWidget {
  final bool isOutOfStock;
  final bool isLowStock;
  final int stock;
  final String unit;

  const _StockBadge({
    required this.isOutOfStock,
    required this.isLowStock,
    required this.stock,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: PosColors.dangerLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: PosColors.danger.withValues(alpha: 0.2)),
        ),
        child: const Text(
          'Habis',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: PosColors.danger,
          ),
        ),
      );
    }
    if (isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: PosColors.warningLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: PosColors.warning.withValues(alpha: 0.2)),
        ),
        child: Text(
          '$stock $unit',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: PosColors.warning,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
