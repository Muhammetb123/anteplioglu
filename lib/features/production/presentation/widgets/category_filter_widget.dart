import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';

class CategoryFilterWidget extends StatelessWidget {
  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Tümü',
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          ...categories.map(
            (c) => _Chip(
              label: c.name.tr,
              selected: selectedId == c.id,
              onTap: () => onSelected(c.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.goldGradientColor2 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppColors.goldGradientColor2
                  : const Color(0xff333333),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xff1f1f1f),
            ),
          ),
        ),
      ),
    );
  }
}
