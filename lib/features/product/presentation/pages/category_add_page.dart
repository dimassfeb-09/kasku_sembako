import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event_state.dart';

class CategoryAddPage extends StatefulWidget {
  const CategoryAddPage({Key? key}) : super(key: key);

  @override
  State<CategoryAddPage> createState() => _CategoryAddPageState();
}

class _CategoryAddPageState extends State<CategoryAddPage> {
  final _nameController = TextEditingController();

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
      id: const Uuid().v4(),
      name: name,
    );

    context.read<CategoryBloc>().add(AddCategoryEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kategori'),
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
                    text: 'Tambah Kategori',
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
