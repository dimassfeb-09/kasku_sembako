import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

/// Single source of truth for Pro entitlement gating across the app.
///
/// Reads the app-wide [SubscriptionCubit] (provided in app.dart) and reuses the
/// [SubscriptionStatusEntity.isEntitled] getter, which already handles the
/// offline grace window. This is a client-side UX gate only — for backend
/// features enforcement lives in the server-side RequirePro middleware.
bool isProEntitled(BuildContext context) {
  final state = context.read<SubscriptionCubit>().state;
  return state is SubscriptionStatusLoaded && state.status.isEntitled;
}

/// Shows the standard "Fitur Pro" upsell dialog. Used by in-page action gates
/// (export laporan, tambah pengguna, kustomisasi struk) where the page itself
/// stays free but a specific action is Pro-only.
Future<void> showProUpsell(
  BuildContext context, {
  required String fitur,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.workspace_premium, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          const Text('Fitur Pro'),
        ],
      ),
      content: Text(
        '$fitur hanya tersedia untuk pengguna Pro. Upgrade sekarang untuk '
        'membuka fitur ini.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Nanti'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.push('/subscription/upgrade');
          },
          child: const Text('Upgrade ke Pro'),
        ),
      ],
    ),
  );
}
