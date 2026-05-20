import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../product/domain/entities/category_entity.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event_state.dart';
import '../bloc/pos_setup_cubit.dart';
import '../widgets/customer_bar.dart';
import '../widgets/cart_item.dart' as mod_cart;
import '../widgets/cart_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../widgets/pos_dialogs.dart';
import '../widgets/product_card.dart';
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
            body: Center(child: CircularProgressIndicator(color: _C.primary)),
          );
        }
        if (setupState is PosSetupError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gagal memuat POS: ${setupState.message}',
                    style: const TextStyle(color: _C.danger),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<PosSetupCubit>().load(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.primary,
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (setupState is PosSetupLoaded) {
          final categories = setupState.categories;
          final customers = setupState.customers;

          return Scaffold(
            backgroundColor: _C.surface,
            appBar: AppBar(
              backgroundColor: _C.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: _C.border,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      color: _C.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Kasir POS',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () => _showClearCartDialog(context),
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
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
                        vertical: 6,
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
                        borderRadius: BorderRadius.circular(10),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                          border: const Border(
                            top: BorderSide(color: _C.border),
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
                                      '$totalItems Item Terpilih',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _C.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      state.total.toRupiah(),
                                      style: const TextStyle(
                                        fontSize: 18,
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
                                  Icons.shopping_cart_checkout_rounded,
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
                                    borderRadius: BorderRadius.circular(10),
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
