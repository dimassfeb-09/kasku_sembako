import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../di/injection.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../../category/domain/usecases/category_usecases.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/searchable_dropdown.dart';
import '../../../../core/theme/app_colors.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({Key? key}) : super(key: key);

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _customUnitController = TextEditingController();
  String _selectedUnit = 'Pcs';
  final List<String> _commonUnits = const [
    'Pcs',
    'Kilogram',
    'Gram',
    'Liter',
    'Pack',
    'Dus',
    'Bungkus',
    'Renteng',
    'Lusin',
    'Botol',
    'Kaleng',
    'Lainnya',
  ];

  List<CategoryEntity> _categories = [];
  String? _selectedCategoryId;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final getCategories = sl<GetCategoriesUseCase>();
    final result = await getCategories();
    result.fold((failure) => null, (categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  void _showStyledSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? AppColors.dangerLight
            : AppColors.successLight,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: isError ? AppColors.danger : AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: isError ? AppColors.danger : AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Foto Produk',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _imagePath = image.path;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Ambil Foto',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _imagePath = image.path;
                      });
                    }
                  },
                ),
                if (_imagePath != null) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.dangerLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Hapus Foto',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imagePath = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final barcode = _barcodeController.text.trim();
    final name = _nameController.text.trim();
    final pPrice = double.tryParse(_purchasePriceController.text) ?? 0;
    final sPrice = double.tryParse(_sellingPriceController.text) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final unit = _selectedUnit == 'Lainnya'
        ? _customUnitController.text.trim()
        : _selectedUnit;

    if (barcode.isEmpty || name.isEmpty || unit.isEmpty) {
      _showStyledSnackBar('Mohon lengkapi semua field wajib', isError: true);
      return;
    }

    if (pPrice <= 0 || sPrice <= 0) {
      _showStyledSnackBar(
        'Harga beli dan harga jual harus lebih besar dari 0',
        isError: true,
      );
      return;
    }

    if (sPrice < pPrice) {
      _showStyledSnackBar(
        'Harga jual tidak boleh kurang dari harga beli',
        isError: true,
      );
      return;
    }

    String? localImagePath;
    if (_imagePath != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final String extension = p.extension(_imagePath!);
        final String fileName = 'product_${const Uuid().v4()}$extension';
        final File savedImage = await File(
          _imagePath!,
        ).copy('${directory.path}/$fileName');
        localImagePath = savedImage.path;
      } catch (e) {
        localImagePath = _imagePath;
      }
    }

    final entity = ProductEntity(
      id: const Uuid().v4(),
      barcode: barcode,
      name: name,
      purchasePrice: pPrice,
      sellingPrice: sPrice,
      stock: stock,
      unit: unit,
      isActive: true,
      categoryId: _selectedCategoryId,
      imagePath: localImagePath,
    );

    if (mounted) {
      context.read<ProductBloc>().add(AddProductEvent(entity));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        title: const Text(
          'Tambah Produk',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            context.pop();
          } else if (state is ProductError) {
            _showStyledSnackBar(state.message, isError: true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_imagePath!),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 24,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tambah Foto',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              AppInput(
                label: 'Barcode',
                controller: _barcodeController,
                hintText: 'Scan atau ketik kode barcode',
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Nama Produk',
                controller: _nameController,
                hintText: 'Contoh: Minyak Goreng Bimoli 1L',
              ),
              const SizedBox(height: 16),
              SearchableDropdown<CategoryEntity>(
                label: 'KATEGORI',
                hint: 'Pilih Kategori (Opsional)',
                searchHint: 'Cari Kategori...',
                noDataMessage: 'Kategori tidak ada',
                items: _categories,
                selectedValue: _selectedCategoryId != null
                    ? _categories.firstWhere((c) => c.id == _selectedCategoryId)
                    : null,
                itemToString: (category) => category.name,
                onChanged: (category) {
                  setState(() {
                    _selectedCategoryId = category?.id;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Harga Beli',
                      controller: _purchasePriceController,
                      keyboardType: TextInputType.number,
                      hintText: 'Rp 0',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppInput(
                      label: 'Harga Jual',
                      controller: _sellingPriceController,
                      keyboardType: TextInputType.number,
                      hintText: 'Rp 0',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Stok Awal',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      hintText: '0',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SearchableDropdown<String>(
                      label: 'SATUAN',
                      hint: 'Pilih Satuan',
                      searchHint: 'Cari Satuan...',
                      noDataMessage: 'Satuan tidak ada',
                      items: _commonUnits,
                      selectedValue: _selectedUnit,
                      itemToString: (u) => u,
                      onChanged: (u) {
                        setState(() {
                          _selectedUnit = u ?? 'Pcs';
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (_selectedUnit == 'Lainnya') ...[
                const SizedBox(height: 16),
                AppInput(
                  label: 'Tulis Satuan Kustom',
                  controller: _customUnitController,
                  hintText: 'Contoh: Meter, Box, Ikat',
                ),
              ],
              const SizedBox(height: 36),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  return AppButton(
                    text: 'Tambah Produk',
                    isLoading: state is ProductLoading,
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
