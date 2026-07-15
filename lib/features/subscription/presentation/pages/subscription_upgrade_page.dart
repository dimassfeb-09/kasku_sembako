import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../account/presentation/bloc/account_bloc.dart';
import '../../../account/presentation/bloc/account_state.dart';
import '../../domain/entities/subscription_status_entity.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

class SubscriptionUpgradePage extends StatefulWidget {
  const SubscriptionUpgradePage({super.key});

  @override
  State<SubscriptionUpgradePage> createState() =>
      _SubscriptionUpgradePageState();
}

class _SubscriptionUpgradePageState extends State<SubscriptionUpgradePage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Langganan Pro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, accountState) {
          if (accountState is! AccountSignedIn) {
            return _SignInPrompt(
              onSignIn: () => context.push('/account/login'),
            );
          }
          return BlocConsumer<SubscriptionCubit, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              }
            },
            builder: (context, state) {
              final status = _statusOf(state);
              final isPro = status?.isEntitled ?? false;
              final isBusy = state is SubscriptionPurchaseInProgress;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium,
                                color: Colors.amber,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Kasirku Pro',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              if (isPro)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Aktif',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Rp10.000 / bulan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cadangkan database toko Anda ke cloud dan pulihkan kapan saja.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          if (status?.expiresAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Berlaku hingga ${status!.expiresAt}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isPro)
                      AppButton(
                        text: 'Berlangganan Pro',
                        isLoading: isBusy,
                        onPressed: () =>
                            context.read<SubscriptionCubit>().purchasePro(),
                      ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Pulihkan Pembelian',
                      isOutline: true,
                      isLoading: isBusy,
                      onPressed: () =>
                          context.read<SubscriptionCubit>().restorePurchases(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  SubscriptionStatusEntity? _statusOf(SubscriptionState state) {
    if (state is SubscriptionStatusLoaded) return state.status;
    if (state is SubscriptionPurchaseInProgress) return state.status;
    if (state is SubscriptionError) return state.previous;
    if (state is SubscriptionStatusLoading) return state.previous;
    return null;
  }
}

class _SignInPrompt extends StatelessWidget {
  final VoidCallback onSignIn;
  const _SignInPrompt({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            const Text(
              'Masuk ke akun toko untuk berlangganan Pro',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppButton(text: 'Masuk / Daftar Akun Toko', onPressed: onSignIn),
          ],
        ),
      ),
    );
  }
}
