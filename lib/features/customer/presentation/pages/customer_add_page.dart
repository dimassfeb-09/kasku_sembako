import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(title: const Text('Tambah Pelanggan')),
      body: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            context.pop();
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(label: 'Nama Pelanggan', controller: _nameController),
              const SizedBox(height: 16),
              AppInput(
                label: 'Nomor HP',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Hutang / Piutang Awal',
                controller: _debtController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppInput(label: 'Catatan', controller: _notesController),
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
    );
  }
}
