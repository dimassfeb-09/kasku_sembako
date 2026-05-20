import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event_state.dart';

class CategoryEditPage extends StatefulWidget {
  final CategoryEntity category;
  const CategoryEditPage({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kategori wajib diisi')),
      );
      return;
    }

    final entity = CategoryEntity(
      id: widget.category.id,
      name: name,
    );

    context.read<CategoryBloc>().add(UpdateCategoryEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Kategori'),
      ),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            context.pop();
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(label: 'Nama Kategori', controller: _nameController),
              const SizedBox(height: 32),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  return AppButton(
                    text: 'Simpan Perubahan',
                    isLoading: state is CategoryLoading,
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
