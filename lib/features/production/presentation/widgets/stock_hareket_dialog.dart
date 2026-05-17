import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/stock_movement_model.dart' show StockMovementType;
import '../../domain/entities/product_entity.dart';
import '../../logic/stock_movement/stock_movement_cubit.dart';

class StockHareketDialog extends StatefulWidget {
  const StockHareketDialog({
    super.key,
    required this.type,
    required this.product,
    required this.cubit,
  });

  final StockMovementType type;
  final ProductEntity product;
  final StockMovementCubit cubit;

  @override
  State<StockHareketDialog> createState() => _StockHareketDialogState();
}

class _StockHareketDialogState extends State<StockHareketDialog> {
  int _quantity = 1;
  final _noteController = TextEditingController();
  final _firmController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _firmController.dispose();
    super.dispose();
  }

  String get _title => widget.type == StockMovementType.in_
      ? 'Giriş Detayları'
      : 'Çıkış Detayları';

  void _save() {
    Navigator.pop(context);
    widget.cubit.addStockMovement(
      widget.product.id,
      type: widget.type,
      quantity: _quantity,
      sourceFirm: _firmController.text.isEmpty ? null : _firmController.text,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _title,
                      style: const TextStyle(
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
              const SizedBox(height: 16),
              const Text(
                'Miktar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfff0f0f0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _CounterBtn(
                      icon: Icons.remove,
                      onTap: () => setState(
                        () => _quantity = (_quantity - 1).clamp(1, 9999),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _CounterBtn(
                      icon: Icons.add,
                      onTap: () => setState(() => _quantity++),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.product.unit,
                      style: const TextStyle(color: Color(0xff5e5e5e)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'İşlem Tarihi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xfff0f0f0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(dateStr, style: const TextStyle(fontSize: 15)),
              ),
              if (widget.type == StockMovementType.out) ...[
                const SizedBox(height: 12),
                const Text(
                  'Çıkış Yapılacak Birim',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xfff0f0f0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.product.unit,
                      isExpanded: true,
                      items: [widget.product.unit]
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  const _CounterBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.goldGradientColor2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
