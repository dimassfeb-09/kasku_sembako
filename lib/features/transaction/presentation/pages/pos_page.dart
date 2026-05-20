import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event_state.dart';
import '../bloc/pos_setup_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductsEvent());
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
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(
                    color: _C.border,
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
                  const SizedBox(width: 12),
                  const Column(
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
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton.icon(
                    onPressed: () => _showClearCartDialog(context),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: _C.danger,
                    ),
                    label: const Text(
                      'Kosongkan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.danger,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: _C.dangerLight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: BlocListener<PosBloc, PosState>(
              listener: (context, state) {
                if (state is PosCheckoutSuccess) {
                  context.read<ProductBloc>().add(LoadProductsEvent());
                  _showCheckoutSuccessDialog(context, state);
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
                          child: PosProductCatalogPane(categories: categories),
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
            bottomNavigationBar: !isTablet
                ? BlocBuilder<PosBloc, PosState>(
                    builder: (context, state) {
                      if (state.cartItems.isEmpty)
                        return const SizedBox.shrink();
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
                              color: Colors.black.withOpacity(0.06),
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
                  )
                : null,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
