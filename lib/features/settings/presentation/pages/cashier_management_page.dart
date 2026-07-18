import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../di/injection.dart' as di;
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';

typedef _C = AppColors;

class CashierManagementPage extends StatefulWidget {
  const CashierManagementPage({super.key});

  @override
  State<CashierManagementPage> createState() => _CashierManagementPageState();
}

class _CashierManagementPageState extends State<CashierManagementPage> {
  List<LocalCashier> _cashiers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = di.sl<AppDatabase>();
    final rows = await (db.select(
      db.localCashiers,
    )..orderBy([(c) => OrderingTerm(expression: c.sortOrder)])).get();
    if (mounted) {
      setState(() {
        _cashiers = rows;
        _loading = false;
      });
    }
  }

  Future<void> _addOrEdit({LocalCashier? existing}) async {
    final isPro =
        context.read<SubscriptionCubit>().state is SubscriptionStatusLoaded &&
        (context.read<SubscriptionCubit>().state as SubscriptionStatusLoaded)
            .status
            .isEntitled;

    if (!isPro && _cashiers.isNotEmpty && existing == null) {
      showProUpsell(context, fitur: 'Multi-karyawan');
      return;
    }

    final nameC = TextEditingController(text: existing?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          existing != null ? 'Edit Karyawan' : 'Tambah Karyawan',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: nameC,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nama karyawan',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
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
            onPressed: () => Navigator.pop(ctx, nameC.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              existing != null ? 'Simpan' : 'Tambah',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    final db = di.sl<AppDatabase>();
    if (existing != null) {
      await (db.update(db.localCashiers)
            ..where((c) => c.id.equals(existing.id)))
          .write(LocalCashiersCompanion(name: Value(result)));
    } else {
      await db
          .into(db.localCashiers)
          .insert(
            LocalCashiersCompanion.insert(
              id: const Uuid().v4(),
              name: result,
              sortOrder: Value(_cashiers.length),
            ),
          );
    }
    await _load();
  }

  Future<void> _delete(LocalCashier c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Karyawan',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Hapus "${c.name}" dari daftar karyawan?',
          style: const TextStyle(fontSize: 13, color: _C.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.w600, color: _C.danger),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final db = di.sl<AppDatabase>();
    await (db.delete(db.localCashiers)..where((t) => t.id.equals(c.id))).go();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: const Text(
          'Kelola Karyawan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
          ),
        ),
        shape: const Border(bottom: BorderSide(color: _C.borderLight)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        backgroundColor: _C.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _C.primary))
          : _cashiers.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 48,
                    color: _C.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada karyawan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _C.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tambahkan karyawan untuk bertugas di POS',
                    style: TextStyle(fontSize: 12, color: _C.textMuted),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: _cashiers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final c = _cashiers[i];
                return Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _C.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: _C.textMuted,
                        ),
                        onPressed: () => _addOrEdit(existing: c),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: _C.danger,
                        ),
                        onPressed: () => _delete(c),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
