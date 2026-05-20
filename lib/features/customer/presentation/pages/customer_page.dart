import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event_state.dart';
import '../bloc/debt_bloc.dart';
import '../bloc/debt_event_state.dart';
import '../widgets/customer_list_item.dart';
import '../../../../core/theme/app_colors.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Manajemen Pelanggan'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, size: 24),
              onPressed: () {
                context.push('/customers/add').then((_) {
                  context.read<CustomerBloc>().add(LoadCustomersEvent());
                });
              },
              tooltip: 'Tambah Pelanggan',
            ),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CustomerBloc, CustomerState>(
            listener: (context, state) {
              if (state is CustomerOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.read<CustomerBloc>().add(LoadCustomersEvent());
              } else if (state is CustomerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
          ),
          BlocListener<DebtBloc, DebtState>(
            listener: (context, state) {
              if (state is DebtOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.read<CustomerBloc>().add(LoadCustomersEvent());
              } else if (state is DebtError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<CustomerBloc, CustomerState>(
          buildWhen: (previous, current) =>
              current is CustomerLoading || current is CustomerLoaded,
          builder: (context, state) {
            if (state is CustomerLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is CustomerLoaded) {
              var customers = state.customers;

              // Apply search filter in UI
              final query = _searchController.text.trim().toLowerCase();
              if (query.isNotEmpty) {
                customers = customers.where((c) {
                  return c.name.toLowerCase().contains(query) ||
                      (c.phone != null && c.phone!.contains(query));
                }).toList();
              }

              return Column(
                children: [
                  // Search Input Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.white,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau nomor HP pelanggan...',
                        hintStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Expanded(
                    child: customers.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_outline_rounded,
                                    size: 48,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'Pelanggan tidak ditemukan'
                                        : 'Belum ada pelanggan',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              return CustomerListItem(customer: customer);
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
