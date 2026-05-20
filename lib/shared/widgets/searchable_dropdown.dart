import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final String searchHint;
  final String noDataMessage;
  final List<T> items;
  final T? selectedValue;
  final String Function(T) itemToString;
  final void Function(T?) onChanged;
  final bool Function(T, String)? filterFn;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemToString,
    required this.onChanged,
    this.selectedValue,
    this.searchHint = 'Cari...',
    this.noDataMessage = 'Kategori tidak ada',
    this.filterFn,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _DropdownSearchSheet<T>(
              items: widget.items,
              itemToString: widget.itemToString,
              selectedValue: widget.selectedValue,
              onChanged: widget.onChanged,
              searchHint: widget.searchHint,
              noDataMessage: widget.noDataMessage,
              filterFn: widget.filterFn,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.selectedValue != null;
    final displayText = hasValue
        ? widget.itemToString(widget.selectedValue as T)
        : widget.hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _showSearchBottomSheet,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownSearchSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedValue;
  final String Function(T) itemToString;
  final void Function(T?) onChanged;
  final String searchHint;
  final String noDataMessage;
  final bool Function(T, String)? filterFn;
  final ScrollController scrollController;

  const _DropdownSearchSheet({
    required this.items,
    required this.itemToString,
    required this.onChanged,
    required this.searchHint,
    required this.noDataMessage,
    required this.scrollController,
    this.selectedValue,
    this.filterFn,
  });

  @override
  State<_DropdownSearchSheet<T>> createState() =>
      _DropdownSearchSheetState<T>();
}

class _DropdownSearchSheetState<T> extends State<_DropdownSearchSheet<T>> {
  final _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items.where((item) {
          if (widget.filterFn != null) {
            return widget.filterFn!(item, query);
          }
          final itemStr = widget.itemToString(item).toLowerCase();
          return itemStr.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          // List of items
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.dangerLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.danger,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.noDataMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected =
                          widget.selectedValue != null &&
                          widget.selectedValue == item;
                      final itemText = widget.itemToString(item);

                      return ListTile(
                        onTap: () {
                          widget.onChanged(item);
                          Navigator.pop(context);
                        },
                        title: Text(
                          itemText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        minVerticalPadding: 12,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
