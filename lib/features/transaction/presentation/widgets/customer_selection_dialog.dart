import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event_state.dart';
import '../bloc/quick_customer_cubit.dart';

typedef _C = AppColors;

class CustomerSelectionDialog extends StatelessWidget {
  final PosState posState;
  final List<CustomerEntity> customers;
  final Function(CustomerEntity) onCustomerAdded;

  const CustomerSelectionDialog({
    super.key,
    required this.posState,
    required this.customers,
    required this.onCustomerAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: _C.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pilih Pelanggan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => QuickAddCustomerDialog(
                          onCustomerAdded: (newCustomer) {
                            onCustomerAdded(newCustomer);
                            Navigator.pop(
                              context,
                            ); // Tutup dialog pemilihan pelanggan
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: _C.primary,
                    ),
                    label: const Text(
                      'Pelanggan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: _C.border),
            // Pelanggan Umum
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _C.border),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: _C.textSecondary,
                  size: 20,
                ),
              ),
              title: const Text(
                'Pelanggan Umum',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Tanpa nama terdaftar',
                style: TextStyle(fontSize: 12, color: _C.textSecondary),
              ),
              onTap: () {
                context.read<PosBloc>().add(const SelectCustomerEvent(null));
                Navigator.pop(context);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: Divider(color: _C.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau pilih pelanggan',
                      style: TextStyle(fontSize: 11, color: _C.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: _C.border)),
                ],
              ),
            ),
            // Customer list
            Flexible(
              child: customers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_alt_1_outlined,
                            size: 40,
                            color: _C.textMuted,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Belum ada data pelanggan.',
                            style: TextStyle(color: _C.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final c = customers[index];
                        final isSelected =
                            posState.selectedCustomer?.id == c.id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _C.primarySurface
                                  : _C.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                c.name.isNotEmpty
                                    ? c.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? _C.primary
                                      : _C.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _C.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            c.phone ?? 'Tidak ada telepon',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.textSecondary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: _C.success,
                                  size: 20,
                                )
                              : null,
                          selected: isSelected,
                          selectedTileColor: _C.primaryLight,
                          onTap: () {
                            context.read<PosBloc>().add(
                              SelectCustomerEvent(c),
                            );
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class QuickAddCustomerDialog extends StatefulWidget {
  final Function(CustomerEntity) onCustomerAdded;

  const QuickAddCustomerDialog({super.key, required this.onCustomerAdded});

  @override
  State<QuickAddCustomerDialog> createState() => _QuickAddCustomerDialogState();
}

class _QuickAddCustomerDialogState extends State<QuickAddCustomerDialog> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuickCustomerCubit>(
      create: (_) => sl<QuickCustomerCubit>(),
      child: BlocConsumer<QuickCustomerCubit, QuickCustomerState>(
        listener: (blocCtx, state) {
          if (state is QuickCustomerSuccess) {
            widget.onCustomerAdded(state.customer);
            Navigator.pop(context);
          } else if (state is QuickCustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: _C.danger,
              ),
            );
          }
        },
        builder: (blocCtx, state) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _C.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: _C.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tambah Pelanggan Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _C.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppInput(
                      label: 'Nama Pelanggan',
                      controller: nameController,
                      readOnly: state is QuickCustomerLoading,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Nomor HP (Opsional)',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      readOnly: state is QuickCustomerLoading,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: state is QuickCustomerLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: _C.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: state is QuickCustomerLoading
                              ? null
                              : () {
                                  final name = nameController.text.trim();
                                  final phone = phoneController.text.trim();
                                  blocCtx
                                      .read<QuickCustomerCubit>()
                                      .addCustomer(name: name, phone: phone);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: state is QuickCustomerLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Simpan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
