import 'package:flutter/material.dart';

import '../../data/models/stock_movement_model.dart';

class StockMovementTileWidget extends StatelessWidget {
  const StockMovementTileWidget({
    super.key,
    required this.movement,
    this.onMenuDelete,
  });

  final StockMovementModel movement;
  final VoidCallback? onMenuDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff1f1f1f),
              ),
            ),
          ),
          SizedBox(
            width: 68,
            child: Center(child: _TypeBadge(type: movement.type)),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 25,
            child: Text(
              '${movement.quantity} ${movement.to?.name ?? ''}',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff1f1f1f),
              ),
            ),
          ),
          if (onMenuDelete != null) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (v) {
                if (v == 'delete') onMenuDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Sil', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String get _label {
    if (movement.sourceFirm != null && movement.sourceFirm!.isNotEmpty) {
      return movement.sourceFirm!;
    }
    if (movement.branchName != null && movement.branchName!.isNotEmpty) {
      return movement.branchName!;
    }
    switch (movement.type) {
      case StockMovementType.in_:
        return 'Giriş';
      case StockMovementType.out:
        return 'Çıkış';
      case StockMovementType.loss:
        return 'Bozuldu';
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final StockMovementType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }

  String get _label {
    switch (type) {
      case StockMovementType.in_:
        return 'Giriş';
      case StockMovementType.out:
        return 'Çıkış';
      case StockMovementType.loss:
        return 'Zayiat';
    }
  }

  Color get _color {
    switch (type) {
      case StockMovementType.in_:
        return const Color(0xff2f7d3b);
      case StockMovementType.out:
        return const Color(0xff3a6db5);
      case StockMovementType.loss:
        return const Color(0xffc44a4a);
    }
  }
}
