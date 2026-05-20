import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/searchable_dropdown.dart';

class UserAddDialog extends StatefulWidget {
  final AppDatabase db;
  final VoidCallback onSuccess;

  const UserAddDialog({super.key, required this.db, required this.onSuccess});

  @override
  State<UserAddDialog> createState() => _UserAddDialogState();
}

class _UserAddDialogState extends State<UserAddDialog> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  String _selectedRole = 'cashier';
  bool _isSaving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();

    if (username.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data')),
      );
      return;
    }

    if (!PinUtils.isValidPin(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN harus berupa angka dan minimal 4 digit'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Cek apakah username sudah ada
      final existingUser = await (widget.db.select(
        widget.db.users,
      )..where((u) => u.username.equals(username))).getSingleOrNull();

      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username sudah terdaftar')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final userId = const Uuid().v4();
      final newUser = User(
        id: userId,
        username: username,
        pinHash: PinUtils.hashPin(pin),
        role: _selectedRole,
        isActive: true,
      );

      await widget.db.into(widget.db.users).insert(newUser);

      // Buat permissions
      final newPerm = Permission(
        id: const Uuid().v4(),
        userId: userId,
        menuProduct: _selectedRole == 'admin',
        menuStock: _selectedRole == 'admin',
        menuReport: _selectedRole == 'admin',
        actionVoid: _selectedRole == 'admin',
      );
      await widget.db.into(widget.db.permissions).insert(newPerm);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna baru berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah pengguna: $e'),
            backgroundColor: Colors.red,
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
    return AlertDialog(
      title: const Text('Tambah Pengguna Baru'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInput(
              label: 'Username / Nama Panggilan',
              controller: _usernameController,
              readOnly: _isSaving,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'PIN Keamanan (Angka)',
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              readOnly: _isSaving,
            ),
            const SizedBox(height: 20),
            SearchableDropdown<String>(
              label: 'Peran Akses (Role)',
              hint: 'Pilih Peran',
              searchHint: 'Cari Peran...',
              noDataMessage: 'Peran tidak ada',
              items: const ['admin', 'cashier'],
              selectedValue: _selectedRole,
              itemToString: (role) => role == 'admin'
                  ? 'Admin (Akses Penuh Toko)'
                  : 'Kasir (Pembatasan Fitur)',
              onChanged: (val) {
                if (!_isSaving && val != null) {
                  setState(() => _selectedRole = val);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
