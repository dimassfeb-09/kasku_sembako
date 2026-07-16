import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/datasources/store_profile_remote_datasource.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/register_step_account.dart';
import '../widgets/register_step_business.dart';
import '../widgets/register_step_confirm.dart';

typedef _C = AppColors;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _ownerController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedCategory = '';

  @override
  void dispose() {
    _pageController.dispose();
    _ownerController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  bool _validateStep1() {
    if (_ownerController.text.trim().isEmpty) {
      _showError('Nama pemilik harus diisi');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Email harus diisi');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showError('Kata sandi minimal 8 karakter');
      return false;
    }
    if (_passwordController.text != _confirmController.text) {
      _showError('Kata sandi tidak cocok');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_businessController.text.trim().isEmpty) {
      _showError('Nama bisnis harus diisi');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _C.danger),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;
    if (_currentStep < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _onRegister() async {
    if (!_validateStep1()) return;
    if (!_validateStep2()) return;

    context.read<AuthBloc>().add(
      RegisterSubmittedEvent(_emailController.text.trim(), _passwordController.text.trim()),
    );
  }

  void _onAuthStateChanged(AuthState state) async {
    if (state is Authenticated) {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'STORE_NAME', value: _businessController.text.trim());
      await storage.write(key: 'STORE_OWNER', value: _ownerController.text.trim());
      await storage.write(key: 'STORE_ADDRESS', value: _addressController.text.trim());
      await storage.write(key: 'STORE_PHONE', value: _phoneController.text.trim());
      await storage.write(key: 'STORE_CATEGORY', value: _selectedCategory);

      final profile = StoreProfileModel(
        ownerName: _ownerController.text.trim(),
        businessName: _businessController.text.trim(),
        businessCategory: _selectedCategory,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      try {
        final token = await storage.read(key: 'USER_SESSION_KEY');
        if (token != null) {
          final dio = buildDio(storage);
          await StoreProfileRemoteDataSourceImpl(dio: dio).save(profile);
        }
      } catch (e) {
        debugPrint('StoreProfile save failed: $e');
      }

      if (context.mounted) context.go('/home');
    } else if (state is AuthError) {
      _showError(state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(RemixIcons.arrow_left_line, color: _C.textPrimary),
          onPressed: _currentStep > 0
              ? () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  )
              : () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _StepDot(isActive: i <= _currentStep, isCurrent: i == _currentStep)),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (_, state) => _onAuthStateChanged(state),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  RegisterStepAccount(
                    ownerController: _ownerController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmController: _confirmController,
                  ),
                  RegisterStepBusiness(
                    businessController: _businessController,
                    phoneController: _phoneController,
                    addressController: _addressController,
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedCategory = v);
                        _categoryController.text = v;
                      }
                    },
                    categoryController: _categoryController,
                  ),
                  RegisterStepConfirm(
                    ownerName: _ownerController.text.trim(),
                    email: _emailController.text.trim(),
                    businessName: _businessController.text.trim(),
                    businessCategory: _selectedCategory,
                    phone: _phoneController.text.trim(),
                    address: _addressController.text.trim(),
                  ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: _C.white,
        border: Border(top: BorderSide(color: _C.borderLight)),
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          if (_currentStep < 2) {
            return Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: AppButton(
                      text: 'Sebelumnya',
                      isOutline: true,
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Selanjutnya',
                    onPressed: _nextStep,
                  ),
                ),
              ],
            );
          }
          return AppButton(
            text: 'Daftar Sekarang',
            isLoading: isLoading,
            onPressed: _onRegister,
          );
        },
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool isActive;
  final bool isCurrent;
  const _StepDot({required this.isActive, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isCurrent ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? _C.primary : _C.borderLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
