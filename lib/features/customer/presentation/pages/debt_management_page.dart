import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirku_sembako/features/customer/presentation/bloc/debt_bloc.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event_state.dart';
import '../bloc/debt_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/customer_entity.dart';
import '../widgets/debt_summary_cards.dart';
import '../widgets/debtors_tab.dart';
import '../widgets/debt_payments_tab.dart';
import '../widgets/debt_search_field.dart';

class DebtManagementPage extends StatefulWidget {
  const DebtManagementPage({super.key});

  @override
  State<DebtManagementPage> createState() => _DebtManagementPageState();
}

class _DebtManagementPageState extends State<DebtManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<CustomerBloc>().add(LoadCustomersEvent());
    context.read<DebtBloc>().add(LoadDebtPaymentsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Manajemen Hutang Piutang'),
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Daftar Piutang Pelanggan'),
              Tab(text: 'Riwayat Cicilan/Pelunasan'),
            ],
          ),
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
                  _loadData();
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
                  _loadData();
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
          child: _DebtPageContent(
            searchController: _searchController,
            onRefresh: _loadData,
          ),
        ),
      ),
    );
  }
}

class _DebtPageContent extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback onRefresh;

  const _DebtPageContent({
    required this.searchController,
    required this.onRefresh,
  });

  @override
  State<_DebtPageContent> createState() => _DebtPageContentState();
}

class _DebtPageContentState extends State<_DebtPageContent> {
  List<CustomerEntity> _customers = [];
  dynamic _payments = [];
  bool _isLoadingCustomers = true;
  bool _isLoadingPayments = true;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerBloc, CustomerState>(
          listener: (context, state) {
            if (state is CustomerLoaded) {
              setState(() {
                _customers = state.customers;
                _isLoadingCustomers = false;
              });
            }
          },
        ),
        BlocListener<DebtBloc, DebtState>(
          listener: (context, state) {
            if (state is DebtPaymentsLoaded) {
              setState(() {
                _payments = state.payments;
                _isLoadingPayments = false;
              });
            }
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          widget.onRefresh();
        },
        child: Column(
          children: [
            // Top Summary Cards
            DebtSummaryCards(customers: _customers),

            // Search field
            DebtSearchField(
              controller: widget.searchController,
              onChanged: () => setState(() {}),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Debtors list
                  DebtorsTab(
                    customers: _customers,
                    searchQuery: widget.searchController.text,
                    isLoading: _isLoadingCustomers,
                  ),
                  // Tab 2: Payments list
                  DebtPaymentsTab(
                    customers: _customers,
                    payments: _payments,
                    searchQuery: widget.searchController.text,
                    isLoading: _isLoadingPayments,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
