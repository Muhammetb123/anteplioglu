import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/gold_gradient_icon_button.dart';
import '../../data/models/product_model.dart';
import '../../data/models/stock_movement_model.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../logic/product/product_cubit.dart';
import '../../logic/product/product_state.dart';
import '../widgets/stock_movement_tile_widget.dart';

@RoutePage()
class UrunDetayiPage extends StatelessWidget {
  const UrunDetayiPage({
    super.key,
    @PathParam('productId') required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductCubit(getIt<IProductRepository>())
            ..loadProductDetail(productId),
      child: _UrunDetayiView(productId: productId),
    );
  }
}

class _UrunDetayiView extends StatelessWidget {
  const _UrunDetayiView({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
        leading: Center(
          child: GoldGradientIconButton(
            icon: Icons.arrow_back_ios_new,
            iconColor: Colors.black,
            onPressed: () => context.router.maybePop(),
          ),
        ),
        title: const Text(
          'Ürün Detayı',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          GoldGradientIconButton(
            icon: Icons.more_vert,
            iconColor: Colors.black,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.read<ProductCubit>().loadProductDetail(productId);
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          if (state is! ProductDetailLoaded) {
            return const SizedBox.shrink();
          }

          final product = state.product;

          return RefreshIndicator(
            onRefresh: () =>
                context.read<ProductCubit>().loadProductDetail(productId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProductInfoCard(product: product),
                const SizedBox(height: 12),
                _AraDolap(quantity: product.quantity, unit: product.unit),
                const SizedBox(height: 12),
                _ActionButtons(product: product),
                const SizedBox(height: 20),
                _SonAktiviteler(
                  movements: product.recentMovements,
                  productId: productId,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xffe7eaec),
                    child: const Icon(
                      Icons.bakery_dining_outlined,
                      color: Color(0xffc2a463),
                      size: 26,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  product.categoryName.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff5e5e5e),
                  ),
                ),
                Text(
                  'Birim ${product.unit}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff5e5e5e),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mainColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.categoryName.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Switch(
                    value: product.isActive,
                    onChanged: (val) => context
                        .read<ProductCubit>()
                        .updateProduct(product.id, isActive: val),
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.mainColor,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xffB6BBC0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _showEditSheet(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _UrunGuncelleSheet(
        product: product,
        cubit: context.read<ProductCubit>(),
      ),
    );
  }
}

class _AraDolap extends StatelessWidget {
  const _AraDolap({required this.quantity, required this.unit});

  final num quantity;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text(
            'Ara Dolap',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            '$quantity',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: const TextStyle(fontSize: 14, color: Color(0xff5e5e5e)),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionBtn(
          icon: Icons.download_outlined,
          label: 'Giriş',
          onTap: () => _showStockSheet(context, StockMovementType.in_),
        ),
        const SizedBox(width: 10),
        _ActionBtn(
          icon: Icons.upload_outlined,
          label: 'Çıkış',
          onTap: () => _showStockSheet(context, StockMovementType.out),
        ),
        const SizedBox(width: 10),
        _ActionBtn(
          icon: Icons.inventory_2_outlined,
          label: 'Ara Dolap',
          onTap: () => _showAraDolabSheet(context),
        ),
      ],
    );
  }

  void _showStockSheet(BuildContext context, StockMovementType type) {
    showDialog(
      context: context,
      builder: (_) => _StockHareketDialog(
        type: type,
        product: product,
        cubit: context.read<ProductCubit>(),
      ),
    );
  }

  void _showAraDolabSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AraDolabDetayDialog(
        movements: product.recentMovements
            .where((m) => m.type == StockMovementType.in_)
            .toList(),
        productName: product.name.tr,
        productImageUrl: product.imageUrl,
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.mainColor, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SonAktiviteler extends StatelessWidget {
  const _SonAktiviteler({required this.movements, required this.productId});

  final List<StockMovementModel> movements;
  final String productId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Son Aktiviteler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.router.push(TumHareketlerRoute(productId: productId)),
              child: const Text(
                'Tümünü Gör',
                style: TextStyle(
                  color: AppColors.mainColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (movements.isEmpty)
          const Text(
            'Henüz hareket yok',
            style: TextStyle(color: Color(0xff5e5e5e)),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: movements
                  .take(5)
                  .map((m) => StockMovementTileWidget(movement: m))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _StockHareketDialog extends StatefulWidget {
  const _StockHareketDialog({
    required this.type,
    required this.product,
    required this.cubit,
  });

  final StockMovementType type;
  final ProductModel product;
  final ProductCubit cubit;

  @override
  State<_StockHareketDialog> createState() => _StockHareketDialogState();
}

class _StockHareketDialogState extends State<_StockHareketDialog> {
  int _quantity = 100;
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
    widget.cubit.addStockMovement(
      widget.product.id,
      type: widget.type,
      quantity: _quantity,
      sourceFirm: _firmController.text.isEmpty ? null : _firmController.text,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    Navigator.pop(context);
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

class _AraDolabDetayDialog extends StatelessWidget {
  const _AraDolabDetayDialog({
    required this.movements,
    required this.productName,
    this.productImageUrl,
  });

  final List<StockMovementModel> movements;
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
                                        color: Color(0xffc2a463),
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

class _UrunGuncelleSheet extends StatefulWidget {
  const _UrunGuncelleSheet({required this.product, required this.cubit});

  final ProductModel product;
  final ProductCubit cubit;

  @override
  State<_UrunGuncelleSheet> createState() => _UrunGuncelleSheetState();
}

class _UrunGuncelleSheetState extends State<_UrunGuncelleSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name.tr);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    widget.cubit.updateProduct(
      widget.product.id,
      name: {
        'tr': _nameController.text,
        'en': widget.product.name.en,
        'de': widget.product.name.de,
      },
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                  const Expanded(
                    child: Text(
                      'Ürün Bilgilerini Güncelle',
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
              const SizedBox(height: 16),
              const Text(
                'Ürün Görseli',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1f1f1f)),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.product.imageUrl != null
                    ? Image.network(
                        widget.product.imageUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 100,
                        color: const Color(0xffe7eaec),
                        child: const Icon(Icons.image_outlined, size: 40),
                      ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ürün Adı',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1f1f1f)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xfff0f0f0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kategori',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1f1f1f)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xfff0f0f0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(widget.product.categoryName.tr),
              ),
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
