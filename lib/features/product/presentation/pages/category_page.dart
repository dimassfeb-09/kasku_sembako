import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/category_list_content.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Kategori Produk'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, size: 24),
              onPressed: () {
                context.push('/categories/add').then((_) {
                  context.read<CategoryBloc>().add(LoadCategoriesEvent());
                });
              },
              tooltip: 'Tambah Kategori',
            ),
          ),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<CategoryBloc>().add(LoadCategoriesEvent());
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is CategoryLoading || current is CategoryLoaded,
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is CategoryLoaded) {
            return CategoryListContent(categories: state.categories);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
