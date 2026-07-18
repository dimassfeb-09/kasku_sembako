import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event_state.dart';
import '../bloc/pos_setup_cubit.dart';
import '../../domain/entities/held_cart_entity.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/services/activity_log_service.dart';
import '../../../../core/services/stock_alert_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../di/injection.dart' as di;
import '../../data/datasources/transaction_local_datasource.dart';
import '../widgets/pos_dialogs.dart';
import '../widgets/pos_product_catalog_pane.dart';
import '../widgets/pos_cart_pane.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
typedef _C = AppColors;

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final _counterKey = GlobalKey<_DailyCounterState>();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsEvent());
    context.read<PosBloc>().add(LoadHeldCartsEvent());
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  void _showCustomerSelectionDialog(
    BuildContext context,
    PosState posState,
    List<CustomerEntity> customers,
  ) {
    PosDialogs.showCustomerSelectionDialog(
      context: context,
      posState: posState,
      customers: customers,
      onCustomerAdded: (newCustomer) {
        final updatedCustomers = List<CustomerEntity>.from(customers)
          ..add(newCustomer);
        context.read<PosSetupCubit>().updateCustomers(updatedCustomers);
        context.read<PosBloc>().add(SelectCustomerEvent(newCustomer));
      },
    );
  }

  void _showDiscountDialog(BuildContext context, PosState posState) {
    PosDialogs.showDiscountDialog(context: context, posState: posState);
  }

  void _showTaxDialog(BuildContext context, PosState posState) {
    PosDialogs.showTaxDialog(context: context, posState: posState);
  }

  void _showCheckoutDialog(
    BuildContext context,
    List<CustomerEntity> customers,
  ) {
    PosDialogs.showCheckoutDialog(context: context, customers: customers);
  }

  void _showClearCartDialog(BuildContext context) {
    PosDialogs.showClearCartDialog(context);
  }

  void _showHoldDialog(BuildContext context) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.pause_circle_outline_rounded,
              color: _C.warning,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Tahan Pesanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pesanan akan disimpan untuk dilanjutkan nanti.',
              style: TextStyle(fontSize: 13, color: _C.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)',
                hintStyle: const TextStyle(color: _C.textMuted, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _C.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _C.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _C.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PosBloc>().add(
                HoldCartEvent(
                  noteController.text.isEmpty ? null : noteController.text,
                ),
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Tahan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showHeldCartsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: BlocBuilder<PosBloc, PosState>(
            builder: (context, state) {
              final heldCarts = state.heldCarts;

              return Column(
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _C.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _C.warningLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.pause_rounded,
                            color: _C.warning,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pesanan Tertunda',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _C.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                heldCarts.isEmpty
                                    ? 'Belum ada pesanan'
                                    : '${heldCarts.length} pesanan ditahan',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _C.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (heldCarts.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _C.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${heldCarts.length}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _C.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: _C.borderLight),
                  Expanded(
                    child: heldCarts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 44,
                                  color: _C.textMuted.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada pesanan tertunda',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _C.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Pesanan yang ditahan akan muncul di sini',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _C.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: heldCarts.length,
                            itemBuilder: (_, i) => _HeldCartTile(
                              cart: heldCarts[i],
                              onResume: () {
                                context.read<PosBloc>().add(
                                  ResumeCartEvent(heldCarts[i].id),
                                );
                                Navigator.pop(ctx);
                              },
                              onDelete: () {
                                context.read<PosBloc>().add(
                                  DeleteHeldCartEvent(heldCarts[i].id),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCheckoutSuccessDialog(
    BuildContext context,
    PosCheckoutSuccess state,
  ) {
    PosDialogs.showCheckoutSuccessDialog(context: context, state: state);
  }

  void _showQtyEditDialog(BuildContext context, dynamic item) {
    PosDialogs.showQtyEditDialog(context: context, item: item);
  }

  void _showMobileCartBottomSheet(
    BuildContext context,
    List<CustomerEntity> customers,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _C.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Cart Pane
              Expanded(child: _getCartPane(context, customers)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCartPane(BuildContext context, List<CustomerEntity> customers) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        return PosCartPane(
          customers: customers,
          onSelectCustomerTap: () =>
              _showCustomerSelectionDialog(context, state, customers),
          onQtyEditTap: (item) => _showQtyEditDialog(context, item),
          onDiscountTap: () => _showDiscountDialog(context, state),
          onTaxTap: () => _showTaxDialog(context, state),
          onCheckoutTap: () => _showCheckoutDialog(context, customers),
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return BlocBuilder<PosSetupCubit, PosSetupState>(
      builder: (context, setupState) {
        if (setupState is PosSetupLoading) {
          return const Scaffold(
            backgroundColor: _C.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.point_of_sale_rounded,
                    color: _C.primary,
                    size: 64,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Menyiapkan Kasir...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sedang memuat data produk dan pelanggan. Harap tunggu...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _C.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: _C.primary,
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (setupState is PosSetupError) {
          return Scaffold(
            backgroundColor: _C.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: _C.danger,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gagal Menyiapkan Kasir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terjadi kesalahan saat memuat data: ${setupState.message}.\nSilakan periksa koneksi internet Anda atau coba lagi.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _C.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<PosSetupCubit>().load(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Coba Memuat Lagi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (setupState is PosSetupLoaded) {
          final categories = setupState.categories;
          final customers = setupState.customers;

          return Scaffold(
            backgroundColor: _C.background,
            appBar: AppBar(
              backgroundColor: _C.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: _C.border,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      color: _C.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mesin Kasir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _C.textPrimary,
                          ),
                        ),
                        Text(
                          'Siap melayani transaksi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                _CashierSelector(),
                _DailyCounter(key: _counterKey),
                BlocBuilder<PosBloc, PosState>(
                  builder: (context, state) {
                    final heldCount = state.heldCarts.length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: _C.textSecondary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            onSelected: (value) {
                              switch (value) {
                                case 'hold':
                                  _showHoldDialog(context);
                                case 'held':
                                  _showHeldCartsSheet(context);
                                case 'clear':
                                  _showClearCartDialog(context);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'hold',
                                child: _MenuRow(
                                  icon: Icons.pause_rounded,
                                  label: 'Tahan Pesanan',
                                ),
                              ),
                              PopupMenuItem(
                                value: 'held',
                                child: _MenuRow(
                                  icon: Icons.pause_circle_outline_rounded,
                                  label:
                                      'Pesanan Tertunda${heldCount > 0 ? ' ($heldCount)' : ''}',
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'clear',
                                child: _MenuRow(
                                  icon: Icons.delete_outline_rounded,
                                  label: 'Kosongkan',
                                  isDanger: true,
                                ),
                              ),
                            ],
                          ),
                          if (heldCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _C.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$heldCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocListener<PosBloc, PosState>(
                    listener: (context, state) {
                      if (state is PosCheckoutSuccess) {
                        context.read<ProductBloc>().add(LoadProductsEvent());
                        _counterKey.currentState?.refresh();
                        _showCheckoutSuccessDialog(context, state);
                        di.sl<StockAlertService>().checkAndNotify();
                      } else if (state is PosError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: _C.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    child: isTablet
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: PosProductCatalogPane(
                                  categories: categories,
                                ),
                              ),
                              Container(width: 1, color: _C.border),
                              Expanded(
                                flex: 2,
                                child: _getCartPane(context, customers),
                              ),
                            ],
                          )
                        : PosProductCatalogPane(categories: categories),
                  ),
                ),
                if (!isTablet)
                  BlocBuilder<PosBloc, PosState>(
                    builder: (context, state) {
                      if (state.cartItems.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final totalItems = state.cartItems.fold<int>(
                        0,
                        (sum, item) => sum + item.quantity,
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _C.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                          border: const Border(
                            top: BorderSide(color: _C.borderLight, width: 1),
                          ),
                        ),
                        child: SafeArea(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$totalItems Barang Terpilih',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _C.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      state.total.toRupiah(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: _C.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showMobileCartBottomSheet(
                                  context,
                                  customers,
                                ),
                                icon: const Icon(
                                  Icons.shopping_cart_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Lihat Keranjang',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.primary,
                                  foregroundColor: _C.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDanger;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDanger ? _C.danger : _C.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDanger ? _C.danger : _C.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _HeldCartTile extends StatelessWidget {
  final HeldCartEntity cart;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  const _HeldCartTile({
    required this.cart,
    required this.onResume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(cart.createdAt),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(cart.createdAt),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _C.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(cart.createdAt),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _C.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cart.note ?? 'Pesanan Tertunda',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _C.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${cart.totalQty} barang',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _C.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cart.totalAmount.toRupiah(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _SlimButton(
                  label: 'Lanjut',
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  onTap: onResume,
                ),
                const SizedBox(height: 6),
                _SlimButton(
                  label: 'Hapus',
                  backgroundColor: Colors.transparent,
                  foregroundColor: _C.textSecondary,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Hapus Pesanan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        content: const Text(
                          'Pesanan tertunda ini akan dihapus. Lanjutkan?',
                          style: TextStyle(
                            fontSize: 13,
                            color: _C.textSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              onDelete();
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _C.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SlimButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _SlimButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: backgroundColor == Colors.transparent
              ? Border.all(color: _C.border)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

const _dailyLimit = 30;

class _CashierSelector extends StatefulWidget {
  @override
  State<_CashierSelector> createState() => _CashierSelectorState();
}

class _CashierSelectorState extends State<_CashierSelector> {
  String _currentName = 'Admin';
  List<LocalCashier> _cashiers = [];
  bool _loaded = false;
  bool _reloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) _reload(); // refresh data when coming back from other pages
    if (!_loaded || _cashiers.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _cashiers.length > 1 ? () => _showPicker(context) : null,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _C.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_rounded, size: 14, color: _C.primary),
              const SizedBox(width: 4),
              Text(
                _currentName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _C.primary,
                ),
              ),
              if (_cashiers.length > 1) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: _C.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _load() async {
    final storage = di.sl<FlutterSecureStorage>();
    final db = di.sl<AppDatabase>();
    final rows = await (db.select(
      db.localCashiers,
    )..orderBy([(c) => OrderingTerm(expression: c.sortOrder)])).get();
    final cashierId = await storage.read(key: 'CURRENT_CASHIER_ID');
    final current = rows.where((c) => c.id == cashierId).firstOrNull;
    if (mounted) {
      setState(() {
        _cashiers = rows;
        _currentName = current?.name ?? cashierId ?? 'Admin';
        _loaded = true;
      });
    }
  }

  Future<void> _reload() async {
    if (_reloading) return;
    _reloading = true;
    final storage = di.sl<FlutterSecureStorage>();
    final db = di.sl<AppDatabase>();
    final rows = await (db.select(
      db.localCashiers,
    )..orderBy([(c) => OrderingTerm(expression: c.sortOrder)])).get();
    final cashierId = await storage.read(key: 'CURRENT_CASHIER_ID');
    final current = rows.where((c) => c.id == cashierId).firstOrNull;
    final newName = current?.name ?? cashierId ?? 'Admin';
    _reloading = false;
    if (mounted && (_needsUpdate(rows, newName))) {
      setState(() {
        _cashiers = rows;
        _currentName = newName;
      });
    }
  }

  bool _needsUpdate(List<LocalCashier> rows, String newName) {
    if (rows.length != _cashiers.length) return true;
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].id != _cashiers[i].id || rows[i].name != _cashiers[i].name) {
        return true;
      }
    }
    return newName != _currentName;
  }

  void _switchCashier(LocalCashier c) async {
    await di.sl<FlutterSecureStorage>().write(
      key: 'CURRENT_CASHIER_ID',
      value: c.id,
    );
    if (mounted) {
      setState(() {
        _currentName = c.name;
      });
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Karyawan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._cashiers.map(
              (c) => ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c.name[0].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.primary,
                    ),
                  ),
                ),
                title: Text(
                  c.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: c.name == _currentName
                    ? const Icon(
                        Icons.check_rounded,
                        color: _C.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  _switchCashier(c);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DailyCounter extends StatefulWidget {
  const _DailyCounter({super.key});

  @override
  State<_DailyCounter> createState() => _DailyCounterState();
}

class _DailyCounterState extends State<_DailyCounter> {
  int _count = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void refresh() => _load();

  Future<void> _load() async {
    final isPro = isProEntitled(context);
    if (isPro) {
      if (mounted) {
        setState(() {
          _count = 0;
          _loaded = true;
        });
      }
      return;
    }
    try {
      final storage = di.sl<FlutterSecureStorage>();
      final db = di.sl<AppDatabase>();
      final log = di.sl<ActivityLogService>();
      final ds = TransactionLocalDataSourceImpl(
        db: db,
        secureStorage: storage,
        logService: log,
      );
      final count = await ds.countToday();
      if (mounted) {
        setState(() {
          _count = count;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox(width: 60, height: 24);
    if (isProEntitled(context)) return const SizedBox.shrink();

    final remaining = _dailyLimit - _count;
    final color = remaining <= 5 ? _C.danger : _C.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _C.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.border),
        ),
        child: Text(
          '$_count/$_dailyLimit',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
