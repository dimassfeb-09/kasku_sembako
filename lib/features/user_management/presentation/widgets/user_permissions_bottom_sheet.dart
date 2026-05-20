import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import 'permission_switch_tile.dart';

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
            content: const Text(
              'Hak akses pengguna berhasil diperbarui',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF0D9488), // Teal 600 Success
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui hak akses: $e',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: const Color(0xFFEF4444), // Red 500 Error
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 4, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0), // Slate 200
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // User Profile Card Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC), // Slate 50
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF1F5F9), // Slate 100
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDFA), // Teal 50
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Color(0xFF0D9488), // Teal 600
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hak Akses ${widget.user.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF0F172A), // Slate 900
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.user.role.toLowerCase() == 'admin'
                              ? const Color(0xFFF0FDFA) // Teal 50
                              : const Color(0xFFEFF6FF), // Blue 50
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.user.role.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: widget.user.role.toLowerCase() == 'admin'
                                ? const Color(0xFF0D9488) // Teal 600
                                : const Color(0xFF3B82F6), // Blue 600
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF94A3B8), // Slate 400
                  ),
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(6),
                    side: const BorderSide(
                      color: Color(0xFFF1F5F9), // Slate 100
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menu Product Permission Row
          PermissionSwitchTile(
            title: 'Kelola Produk & Kategori',
            subtitle: 'Menambah, mengubah, dan menghapus barang dagangan toko',
            value: menuProduct,
            isSaving: _isSaving,
            onChanged: (val) => setState(() => menuProduct = val),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9), thickness: 1),

          // Menu Stock Permission Row
          PermissionSwitchTile(
            title: 'Akses Manajemen Stok',
            subtitle: 'Melakukan stock opname dan penyesuaian kuantitas manual',
            value: menuStock,
            isSaving: _isSaving,
            onChanged: (val) => setState(() => menuStock = val),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9), thickness: 1),

          // Menu Report Permission Row
          PermissionSwitchTile(
            title: 'Melihat Laporan Keuangan',
            subtitle: 'Akses data laporan laba rugi, omset penjualan harian & pengeluaran',
            value: menuReport,
            isSaving: _isSaving,
            onChanged: (val) => setState(() => menuReport = val),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9), thickness: 1),

          // Action Void Permission Row
          PermissionSwitchTile(
            title: 'Otorisasi Pembatalan (Void)',
            subtitle: 'Membatalkan/menghapus struk transaksi yang telah dicetak',
            value: actionVoid,
            isSaving: _isSaving,
            onChanged: (val) => setState(() => actionVoid = val),
          ),

          const SizedBox(height: 24),

          // Action Button
          ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488), // Teal 600
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
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
                      fontFamily: 'Inter',
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

