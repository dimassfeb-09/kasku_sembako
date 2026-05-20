import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasirku_sembako/core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event_state.dart';

class CustomerEditPage extends StatefulWidget {
  final CustomerEntity customer;
  const CustomerEditPage({super.key, required this.customer});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  late final TextEditingController _debtController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone ?? '');
    _notesController = TextEditingController(text: widget.customer.notes ?? '');
    _debtController = TextEditingController(
      text: widget.customer.debtAmount.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _debtController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final notes = _notesController.text.trim();
    final debt = double.tryParse(_debtController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama pelanggan wajib diisi')),
      );
      return;
    }

    final entity = CustomerEntity(
      id: widget.customer.id,
      name: name,
      phone: phone.isEmpty ? null : phone,
      notes: notes.isEmpty ? null : notes,
      debtAmount: debt,
    );

    context.read<CustomerBloc>().add(UpdateCustomerEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Pelanggan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            context.pop();
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444), // Red 500
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white, // Surface White
                borderRadius: BorderRadius.circular(16), // 16px corners
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: 1,
                ), // Slate 100 border
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000), // Soft diffuse shadow
                    offset: Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppInput(
                    label: 'Nama Pelanggan',
                    controller: _nameController,
                    hintText: 'Masukkan nama lengkap pelanggan',
                  ),
                  const SizedBox(height: 18),
                  AppInput(
                    label: 'Nomor HP',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    hintText: 'e.g. 0812xxxxxxxx',
                  ),
                  const SizedBox(height: 18),
                  AppInput(
                    label: 'Hutang / Piutang',
                    controller: _debtController,
                    keyboardType: TextInputType.number,
                    readOnly:
                        true, // Saldo hutang disarankan dimanage lewat cicilan atau POS belanja
                    hintText: '0',
                  ),
                  const SizedBox(height: 18),
                  AppInput(
                    label: 'Catatan tambahan',
                    controller: _notesController,
                    hintText: 'Alamat atau catatan khusus pelanggan',
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      return AppButton(
                        text: 'Simpan Perubahan',
                        isLoading: state is CustomerLoading,
                        onPressed: _onSave,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
