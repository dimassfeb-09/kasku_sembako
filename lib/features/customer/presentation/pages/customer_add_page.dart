import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasirku_sembako/core/theme/app_colors.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event_state.dart';

class CustomerAddPage extends StatefulWidget {
  const CustomerAddPage({super.key});

  @override
  State<CustomerAddPage> createState() => _CustomerAddPageState();
}

class _CustomerAddPageState extends State<CustomerAddPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _debtController = TextEditingController();

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
      id: const Uuid().v4(),
      name: name,
      phone: phone.isEmpty ? null : phone,
      notes: notes.isEmpty ? null : notes,
      debtAmount: debt,
    );

    context.read<CustomerBloc>().add(AddCustomerEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tambah Pelanggan',
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
                    label: 'Hutang / Piutang Awal',
                    controller: _debtController,
                    keyboardType: TextInputType.number,
                    hintText: '0 (Isi jika ada saldo awal)',
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
                        text: 'Tambah Pelanggan',
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
