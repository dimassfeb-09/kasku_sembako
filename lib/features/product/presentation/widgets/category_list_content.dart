import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event_state.dart';
import 'category_list_item.dart';

class CategoryListContent extends StatefulWidget {
  final List<CategoryEntity> categories;

  const CategoryListContent({
    super.key,
    required this.categories,
  });

  @override
  State<CategoryListContent> createState() => _CategoryListContentState();
}

class _CategoryListContentState extends State<CategoryListContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    var filteredCategories = widget.categories;

    if (query.isNotEmpty) {
      filteredCategories = widget.categories.where((c) {
        return c.name.toLowerCase().contains(query);
      }).toList();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.white,
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari kategori...',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 20,
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
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<CategoryBloc>().add(LoadCategoriesEvent());
            },
            child: filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: AppColors.border,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          query.isNotEmpty
                              ? 'Kategori tidak ditemukan'
                              : 'Belum ada data kategori',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCategories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return CategoryListItem(
                        category: filteredCategories[index],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
