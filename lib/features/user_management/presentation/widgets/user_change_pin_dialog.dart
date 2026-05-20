import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/pin_utils.dart';
import '../../../../shared/widgets/app_input.dart';

class UserChangePinDialog extends StatefulWidget {
  final User user;
  final AppDatabase db;
  final VoidCallback onSuccess;

  const UserChangePinDialog({
    super.key,
    required this.user,
    required this.db,
    required this.onSuccess,
  });

  @override
  State<UserChangePinDialog> createState() => _UserChangePinDialogState();
}

class _UserChangePinDialogState extends State<UserChangePinDialog> {
  final _pinController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN baru tidak boleh kosong')),
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
      await (widget.db.update(widget.db.users)
            ..where((u) => u.id.equals(widget.user.id)))
          .write(UsersCompanion(pinHash: Value(PinUtils.hashPin(pin))));

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui PIN: $e'),
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
      title: Text('Ubah PIN ${widget.user.username}'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            label: 'PIN Baru (Angka)',
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            readOnly: _isSaving,
          ),
        ],
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
