import 'package:flutter/material.dart';
import 'package:kasirku_sembako/features/user_management/presentation/widgets/user_card_tile.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../widgets/user_add_dialog.dart';
import '../widgets/user_change_pin_dialog.dart';
import '../widgets/user_permissions_bottom_sheet.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';

typedef _C = AppColors;

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _db = sl<AppDatabase>();
  List<User> _users = [];
  Map<String, Permission> _userPermissions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await _db.select(_db.users).get();
      final permissions = await _db.select(_db.permissions).get();

      final permissionMap = {for (var p in permissions) p.userId: p};

      // Buat permission default jika belum ada di DB
      for (var user in users) {
        if (!permissionMap.containsKey(user.id)) {
          final newPerm = Permission(
            id: const Uuid().v4(),
            userId: user.id,
            menuProduct: user.role == 'admin',
            menuStock: user.role == 'admin',
            menuReport: user.role == 'admin',
            actionVoid: user.role == 'admin',
          );
          await _db.into(_db.permissions).insert(newPerm);
          permissionMap[user.id] = newPerm;
        }
      }

      setState(() {
        _users = users;
        _userPermissions = permissionMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddUserDialog() {
    // Multi-user is a Pro feature: the first admin is created at setup, so any
    // employee added here requires Pro.
    if (!isProEntitled(context)) {
      showProUpsell(context, fitur: 'Menambah pengguna (karyawan)');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => UserAddDialog(db: _db, onSuccess: _loadData),
    );
  }

  void _showChangePinDialog(User user) {
    showDialog(
      context: context,
      builder: (ctx) =>
          UserChangePinDialog(user: user, db: _db, onSuccess: _loadData),
    );
  }

  void _showPermissionsBottomSheet(User user) {
    final perm = _userPermissions[user.id];
    if (perm == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return UserPermissionsBottomSheet(
          user: user,
          permission: perm,
          db: _db,
          onSuccess: _loadData,
        );
      },
    );
  }

  Future<void> _toggleUserStatus(User user) async {
    if (user.username == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Super Admin bawaan tidak dapat dinonaktifkan'),
        ),
      );
      return;
    }

    try {
      final updated = user.copyWith(isActive: !user.isActive);
      await _db.update(_db.users).replace(updated);
      _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pengguna ${user.username} berhasil diperbarui'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.surface,
      appBar: AppBar(
        title: const Text(
          'Kelola Pengguna & Akses',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _C.textPrimary,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _C.border)),
          ),
          child: ElevatedButton.icon(
            onPressed: _showAddUserDialog,
            icon: const Icon(Icons.person_add_rounded, size: 20),
            label: const Text('Tambah Pengguna Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _C.primary))
          : _users.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 48,
                    color: _C.textMuted,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada pengguna terdaftar.',
                    style: TextStyle(
                      color: _C.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = _users[index];
                return UserCardTile(
                  user: user,
                  onEditPermissions: () => _showPermissionsBottomSheet(user),
                  onChangePin: () => _showChangePinDialog(user),
                  onToggleStatus: (val) => _toggleUserStatus(user),
                );
              },
            ),
    );
  }
}
