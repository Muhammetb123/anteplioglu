import 'package:flutter/material.dart';

import 'package:core/constants/app_colors.dart';
import '../../domain/entities/product_entity.dart';

class ProductCardWidget extends StatelessWidget {
  const ProductCardWidget({
    super.key,
    required this.product,
    required this.onTap,
    required this.onToggle,
  });

  final ProductEntity product;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _ProductImage(imageUrl: product.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                product.name.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1f1f1f),
                ),
              ),
            ),
            Switch(
              value: product.isActive,
              onChanged: onToggle,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.mainColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xffB6BBC0),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder,
            )
          : _placeholder,
    );
  }

  Widget get _placeholder => Container(
        width: 44,
        height: 44,
        color: const Color(0xffe7eaec),
        child: const Icon(Icons.bakery_dining_outlined,
            size: 22, color: AppColors.goldBorderColor),
      );
}
