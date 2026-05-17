
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/gold_gradient_icon_button.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/stock_movement_entity.dart';
import '../../data/models/stock_movement_model.dart' show StockMovementType;

import '../../logic/product/product_cubit.dart';
import '../../logic/product/product_state.dart';
import '../../logic/stock_movement/stock_movement_cubit.dart';
import '../../logic/stock_movement/stock_movement_state.dart';
import '../widgets/stock_movement_tile_widget.dart';
import '../widgets/stock_hareket_dialog.dart';
import '../widgets/ara_dolab_detay_dialog.dart';
import '../widgets/urun_guncelle_dialog.dart';

@RoutePage()
class UrunDetayiPage extends StatelessWidget {
  const UrunDetayiPage({
    super.key,
    @PathParam('productId') required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProductCubit>()..loadProductDetail(productId),
        ),
        BlocProvider(
          create: (_) => getIt<StockMovementCubit>(),
        ),
      ],
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
            isCircle: true,
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProductCubit, ProductState>(
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
          ),
          BlocListener<StockMovementCubit, StockMovementState>(
            listener: (context, state) {
              if (state is StockMovementActionSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                context.read<ProductCubit>().loadProductDetail(productId);
              }
              if (state is StockMovementError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: BlocBuilder<ProductCubit, ProductState>(
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
      ),
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.product});

  final ProductEntity product;

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
                      color: AppColors.goldBorderColor,
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
      builder: (_) => UrunGuncelleDialog(
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

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionBtn(
          icon: Icons.download_outlined,
          label: 'Giriş',
          onTap: () =>
              _showActionSheet(context, StockMovementType.in_, product),
        ),
        const SizedBox(width: 10),
        _ActionBtn(
          icon: Icons.upload_outlined,
          label: 'Çıkış',
          onTap: () =>
              _showActionSheet(context, StockMovementType.out, product),
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

  void _showActionSheet(
    BuildContext context,
    StockMovementType type,
    ProductEntity product,
  ) {
    showDialog(
      context: context,
      builder: (_) => StockHareketDialog(
        type: type,
        product: product,
        cubit: context.read<StockMovementCubit>(),
      ),
    );
  }

  void _showAraDolabSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AraDolabDetayDialog(
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

  final List<StockMovementEntity> movements;
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


