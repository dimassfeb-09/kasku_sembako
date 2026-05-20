import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import 'permission_switch_tile.dart';

typedef _C = AppColors;

class UserPermissionsBottomSheet extends StatefulWidget {
  final User user;
  final Permission permission;
  final AppDatabase db;
  final VoidCallback onSuccess;

  const UserPermissionsBottomSheet({
    super.key,
    required this.user,
    required this.permission,
    required this.db,
    required this.onSuccess,
  });

  @override
  State<UserPermissionsBottomSheet> createState() =>
      _UserPermissionsBottomSheetState();
}

class _UserPermissionsBottomSheetState
    extends State<UserPermissionsBottomSheet> {
  late bool menuProduct;
  late bool menuStock;
  late bool menuReport;
  late bool actionVoid;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    menuProduct = widget.permission.menuProduct;
    menuStock = widget.permission.menuStock;
    menuReport = widget.permission.menuReport;
    actionVoid = widget.permission.actionVoid;
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final updated = widget.permission.copyWith(
        menuProduct: menuProduct,
        menuStock: menuStock,
        menuReport: menuReport,
        actionVoid: actionVoid,
      );
      await widget.db.update(widget.db.permissions).replace(updated);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hak akses pengguna berhasil diperbarui'),
            backgroundColor: _C.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui hak akses: $e'),
            backgroundColor: _C.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hak Akses Pengguna',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pengguna: ${widget.user.username} (${widget.user.role.toUpperCase()})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.textSecondary,
                  ),
                ),
              ],
            ),
          ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _C.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: _C.textSecondary,
                  ),
                ),
                onPressed: _isSaving ? null : () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24, color: _C.border),

          // Menu Product
          PermissionSwitchTile(
            title: 'Kelola Produk & Kategori',
            subtitle: 'Menambah, mengubah, dan menghapus barang dagangan toko',
            value: menuProduct,
            isSaving: _isSaving,
            onChanged: (val) => setState(() => menuProduct = val),
          ),
          const Divider(height: 16, color: _C.border),

          // Menu Stock
          PermissionSwitchTile(
            title: 'Akses Manajemen Stok',
            subtitle: 'Melakukan stock opname dan penyesuaian kuantitas manual',
            value: menuStock,
            isSaving: _isSaving,
            onChanged: (val) => setState(() => menuStock = val),
          ),
          const Divider(height: 16, color: _C.border),

          // Menu Report
          PermissionSwitchTile(
            title: 'Melihat Laporan Keuangan',
            subtitle:
                'Akses data laporan laba rugi, omset penjualan harian & pengeluaran',
            value: menuReport,
            isSaving: _isSaving,
            onChanged: (val) => setState(() => menuReport = val),
          ),
          const Divider(height: 16, color: _C.border),

          // Action Void
          PermissionSwitchTile(
            title: 'Otorisasi Pembatalan (Void)',
            subtitle: 'Membatalkan/menghapus struk transaksi yang telah dicetak',
            value: actionVoid,
            isSaving: _isSaving,
            onChanged: (val) => setState(() => actionVoid = val),
          ),

          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Perbarui Hak Akses',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
