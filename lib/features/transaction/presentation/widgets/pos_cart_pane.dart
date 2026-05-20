import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event_state.dart';
import 'customer_bar.dart';
import 'cart_item.dart' as mod_cart;
import 'cart_summary.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class PosCartPane extends StatelessWidget {
  final List<CustomerEntity> customers;
  final VoidCallback onSelectCustomerTap;
  final Function(dynamic item) onQtyEditTap;
  final VoidCallback onDiscountTap;
  final VoidCallback onTaxTap;
  final VoidCallback onCheckoutTap;

  const PosCartPane({
    super.key,
    required this.customers,
    required this.onSelectCustomerTap,
    required this.onQtyEditTap,
    required this.onDiscountTap,
    required this.onTaxTap,
    required this.onCheckoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        return Container(
          color: _C.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer row
              CustomerBar(
                state: state,
                onTap: onSelectCustomerTap,
              ),
              Container(height: 1, color: _C.border),
              // Cart items
              Expanded(
                child: state.cartItems.isEmpty
                    ? const mod_cart.EmptyCart()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: state.cartItems.length,
                        separatorBuilder: (_, __) => Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: _C.border,
                        ),
                        itemBuilder: (context, index) {
                          final item = state.cartItems[index];
                          return mod_cart.CartItem(
                            item: item,
                            onDecrement: () => context.read<PosBloc>().add(
                                  UpdateCartItemQtyEvent(
                                    item.product,
                                    item.quantity - 1,
                                  ),
                                ),
                            onIncrement: () => context.read<PosBloc>().add(
                                  UpdateCartItemQtyEvent(
                                    item.product,
                                    item.quantity + 1,
                                  ),
                                ),
                            onQtyTap: () => onQtyEditTap(item),
                          );
                        },
                      ),
              ),
              // Summary
              CartSummary(
                state: state,
                onDiscountTap: onDiscountTap,
                onTaxTap: onTaxTap,
                onCheckout: onCheckoutTap,
              ),
            ],
          ),
        );
      },
    );
  }
}
