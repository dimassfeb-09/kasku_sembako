import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class AccountHomePage extends StatelessWidget {
  const AccountHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state is AccountSignedOut) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Akun Toko'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountSignedIn) {
              return _SignedInView(email: state.account.email);
            }
            return _SignedOutView(
              onSignIn: () => context.push('/account/login'),
            );
          },
        ),
      ),
    );
  }
}

class _SignedInView extends StatelessWidget {
  final String email;
  const _SignedInView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF0D9488),
                child: Icon(Icons.storefront, color: Colors.white),
              ),
              title: const Text(
                'Toko',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(email),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.workspace_premium, color: Colors.white),
              ),
              title: const Text(
                'Langganan Pro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Lihat status dan upgrade ke Pro'),
              onTap: () => context.push('/subscription/upgrade'),
            ),
          ),
          const Spacer(),
          AppButton(
            text: 'Keluar dari Akun Toko',
            isOutline: true,
            onPressed: () => context.read<AccountBloc>().add(LogoutEvent()),
          ),
        ],
      ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  final VoidCallback onSignIn;
  const _SignedOutView({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 64,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum masuk ke akun toko',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Masuk atau daftar akun toko untuk mengaktifkan Pro dan cadangan cloud.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(text: 'Masuk / Daftar', onPressed: onSignIn),
          ],
        ),
      ),
    );
  }
}
