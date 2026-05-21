import 'package:flutter/material.dart';
import 'package:core/constants/app_colors.dart';
import '../../domain/entities/stock_movement_entity.dart';

class AraDolabDetayDialog extends StatelessWidget {
  const AraDolabDetayDialog({
    super.key,
    required this.movements,
    required this.productName,
    this.productImageUrl,
  });

  final List<StockMovementEntity> movements;
  final String productName;
  final String? productImageUrl;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ara Dolap Detay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Product card + movement rows
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff2f4f5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      // Product header row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  productImageUrl != null &&
                                      productImageUrl!.isNotEmpty
                                  ? Image.network(
                                      productImageUrl!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 44,
                                      height: 44,
                                      color: const Color(0xffe7eaec),
                                      child: const Icon(
                                        Icons.bakery_dining_outlined,
                                        color: AppColors.goldBorderColor,
                                        size: 22,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xffE0E0E0)),
                      // Movement rows
                      ...movements.map(
                        (m) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${m.quantity} ${m.to?.name ?? 'Tepsi'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                m.createdAt != null
                                    ? 'Üretim Tarihi: ${m.createdAt!.day.toString().padLeft(2, '0')}.${m.createdAt!.month.toString().padLeft(2, '0')}.${m.createdAt!.year}'
                                    : '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff5e5e5e),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
