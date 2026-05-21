import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:shared_ui/widgets/gold_gradient_icon_button.dart';
import '../../data/models/stock_movement_model.dart';

import '../../logic/stock_movement/stock_movement_cubit.dart';
import '../../logic/stock_movement/stock_movement_state.dart';
import '../widgets/stock_movement_tile_widget.dart';

@RoutePage()
class TumHareketlerPage extends StatelessWidget {
  const TumHareketlerPage({
    super.key,
    @PathParam('productId') required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StockMovementCubit>()
        ..loadStockMovements(productId),
      child: _TumHareketlerView(productId: productId),
    );
  }
}

class _TumHareketlerView extends StatefulWidget {
  const _TumHareketlerView({required this.productId});

  final String productId;

  @override
  State<_TumHareketlerView> createState() => _TumHareketlerViewState();
}

class _TumHareketlerViewState extends State<_TumHareketlerView> {
  StockMovementType? _filter;

  void _applyFilter(StockMovementType? type) {
    setState(() => _filter = type);
    context.read<StockMovementCubit>().loadStockMovements(
          widget.productId,
          type: type,
        );
  }

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
        title: const Text('Tüm Hareketler',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tarih',
                      prefixIcon: const Icon(Icons.calendar_today_outlined,
                          size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tümü',
                  selected: _filter == null,
                  onTap: () => _applyFilter(null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Girişi',
                  selected: _filter == StockMovementType.in_,
                  onTap: () => _applyFilter(StockMovementType.in_),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Çıkışı',
                  selected: _filter == StockMovementType.out,
                  onTap: () => _applyFilter(StockMovementType.out),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<StockMovementCubit, StockMovementState>(
              builder: (context, state) {
                if (state is StockMovementLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is StockMovementError) {
                  return Center(child: Text(state.message));
                }
                if (state is! StockMovementsLoaded) {
                  return const SizedBox.shrink();
                }

                if (state.items.isEmpty) {
                  return const Center(child: Text('Hareket bulunamadı'));
                }

                return RefreshIndicator(
                  onRefresh: () => context
                      .read<StockMovementCubit>()
                      .loadStockMovements(widget.productId, type: _filter),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: state.items.length,
                    itemBuilder: (context, i) {
                      final m = state.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: StockMovementTileWidget(
                          movement: m,
                          onMenuDelete: () => context
                              .read<StockMovementCubit>()
                              .deleteStockMovement(widget.productId, m.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldGradientColor2 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.goldGradientColor2
                : const Color(0xffd4bc72),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xff5e5e5e),
          ),
        ),
      ),
    );
  }
}
