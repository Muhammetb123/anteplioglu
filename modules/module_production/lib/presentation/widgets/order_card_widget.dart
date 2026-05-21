import 'package:flutter/material.dart';

import 'package:core/constants/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({
    super.key,
    required this.order,
    required this.branchName,
    required this.onTap,
  });

  final OrderModel order;
  final String branchName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffe7eaec),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    branchName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1f1f1f),
                    ),
                  ),
                ),
                Text(
                  order.orderNumber.isEmpty ? '' : '#${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1f1f1f),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff5e5e5e),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${order.items.length} kalem',
              style: const TextStyle(fontSize: 13, color: Color(0xff5e5e5e)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case OrderStatus.draft:
        return 'Taslak';
      case OrderStatus.accepted:
        return 'Kabul Edildi';
      case OrderStatus.completed:
        return 'Tamamlandı';
      case OrderStatus.cancelled:
        return 'İptal Edildi';
      case OrderStatus.unknown:
        return '';
    }
  }

  Color get _color {
    switch (status) {
      case OrderStatus.draft:
        return const Color(0xff8a8a8a);
      case OrderStatus.accepted:
        return const Color(0xff2f7d3b);
      case OrderStatus.completed:
        return AppColors.mainColor;
      case OrderStatus.cancelled:
        return const Color(0xffc44a4a);
      case OrderStatus.unknown:
        return Colors.grey;
    }
  }
}
