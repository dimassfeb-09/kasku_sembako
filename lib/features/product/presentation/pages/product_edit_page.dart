import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/category_usecases.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/searchable_dropdown.dart';
import '../../../../core/theme/app_colors.dart';

class ProductEditPage extends StatefulWidget {
  final ProductEntity product;
  const ProductEditPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  late final TextEditingController _barcodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _customUnitController;
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
  bool _imageDeleted = false;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.product.barcode);
    _nameController = TextEditingController(text: widget.product.name);
    _purchasePriceController = TextEditingController(
      text: widget.product.purchasePrice.toString(),
    );
    _sellingPriceController = TextEditingController(
      text: widget.product.sellingPrice.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    String initialUnit = widget.product.unit;
    if (initialUnit.toLowerCase() == 'kg') initialUnit = 'Kilogram';
    if (initialUnit.toLowerCase() == 'gr' || initialUnit.toLowerCase() == 'g')
      initialUnit = 'Gram';
    if (initialUnit.toLowerCase() == 'ltr' || initialUnit.toLowerCase() == 'l')
      initialUnit = 'Liter';
    if (initialUnit.toLowerCase() == 'bks') initialUnit = 'Bungkus';
    if (initialUnit.toLowerCase() == 'rtg') initialUnit = 'Renteng';
    if (initialUnit.toLowerCase() == 'lsn') initialUnit = 'Lusin';

    if (_commonUnits.contains(initialUnit)) {
      _selectedUnit = initialUnit;
      _customUnitController = TextEditingController();
    } else {
      _selectedUnit = 'Lainnya';
      _customUnitController = TextEditingController(text: initialUnit);
    }
    _selectedCategoryId = widget.product.categoryId;
    _imagePath = widget.product.imagePath;
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
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
                    _imageDeleted = false;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil Foto'),
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
                    _imageDeleted = false;
                  });
                }
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imagePath = null;
                    _imageDeleted = true;
                  });
                },
              ),
          ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field')),
      );
      return;
    }

    if (pPrice <= 0 || sPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga beli dan harga jual harus lebih besar dari 0'),
        ),
      );
      return;
    }

    if (sPrice < pPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga jual tidak boleh kurang dari harga beli'),
        ),
      );
      return;
    }

    String? localImagePath = widget.product.imagePath;

    if (_imageDeleted) {
      localImagePath = null;
    } else if (_imagePath != null && _imagePath != widget.product.imagePath) {
      // Only copy if it is a new image picked
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
      id: widget.product.id,
      barcode: barcode,
      name: name,
      purchasePrice: pPrice,
      sellingPrice: sPrice,
      stock: stock,
      unit: unit,
      isActive: widget.product.isActive,
      categoryId: _selectedCategoryId,
      imagePath: localImagePath,
    );

    if (mounted) {
      context.read<ProductBloc>().add(UpdateProductEvent(entity));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            context.pop();
          } else if (state is ProductError) {
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
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:
                                _imagePath!.startsWith('/') ||
                                    _imagePath!.contains(':\\') ||
                                    _imagePath!.contains(':/')
                                ? Image.file(
                                    File(_imagePath!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _imagePath!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported_rounded,
                                              size: 36,
                                              color: AppColors.textMuted,
                                            ),
                                  ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 36,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ubah Foto',
                                style: TextStyle(
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
              const SizedBox(height: 24),
              AppInput(label: 'Barcode', controller: _barcodeController),
              const SizedBox(height: 16),
              AppInput(label: 'Nama Produk', controller: _nameController),
              const SizedBox(height: 16),
              SearchableDropdown<CategoryEntity>(
                label: 'Kategori',
                hint: 'Pilih Kategori (Opsional)',
                searchHint: 'Cari Kategori...',
                noDataMessage: 'Kategori tidak ada',
                items: _categories,
                selectedValue: _selectedCategoryId != null
                    ? () {
                        for (var c in _categories) {
                          if (c.id == _selectedCategoryId) return c;
                        }
                        return null;
                      }()
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
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Harga Beli',
                      controller: _purchasePriceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppInput(
                      label: 'Harga Jual',
                      controller: _sellingPriceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await context.pushNamed<bool>(
                          'adjust_stock',
                          extra: widget.product,
                        );
                        if (result == true) {
                          final db = sl<AppDatabase>();
                          final updatedProduct = await (db.select(db.products)
                                ..where((tbl) => tbl.id.equals(widget.product.id)))
                              .getSingleOrNull();
                          if (updatedProduct != null) {
                            setState(() {
                              _stockController.text =
                                  updatedProduct.stock.toString();
                            });
                          }
                        }
                      },
                      child: AbsorbPointer(
                        child: AppInput(
                          label: 'Stok',
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SearchableDropdown<String>(
                      label: 'Satuan',
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
              const SizedBox(height: 32),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  return AppButton(
                    text: 'Simpan Perubahan',
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
