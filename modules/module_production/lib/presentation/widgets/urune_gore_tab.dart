import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../logic/orders/orders_cubit.dart';
import '../../logic/orders/orders_state.dart';

class UruneGoreTab extends StatefulWidget {
  const UruneGoreTab({super.key});

  @override
  State<UruneGoreTab> createState() => _UruneGoreTabState();
}

class _UruneGoreTabState extends State<UruneGoreTab> {
  String? _selectedCategoryId;

  void _selectCategory(BuildContext context, String? id) {
    setState(() => _selectedCategoryId = id);
    context.read<OrdersCubit>().loadOrdersByProduct(categoryId: id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final categoryNames = state is OrdersByProductLoaded
            ? state.categoryNames
            : <String, String>{};

        final isLoading = state is OrdersLoading;
        final loaded = state is OrdersByProductLoaded ? state : null;

        return Column(
          children: [
            if (categoryNames.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _OrderCategoryChip(
                      label: 'Tümü',
                      selected: _selectedCategoryId == null,
                      onTap: () => _selectCategory(context, null),
                    ),
                    ...categoryNames.entries.map(
                      (e) => _OrderCategoryChip(
                        label: e.value,
                        selected: _selectedCategoryId == e.key,
                        onTap: () => _selectCategory(context, e.key),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is OrdersError
                  ? Center(child: Text(state.message))
                  : loaded == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<OrdersCubit>().loadOrdersByProduct(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: loaded.data.byProduct.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final item = loaded.data.byProduct[i];
                          final detail = loaded.expandedDetails[item.productId];
                          return _ProductAccordion(
                            item: item,
                            detail: detail,
                            onExpand: () => context
                                .read<OrdersCubit>()
                                .loadOrderByProductDetail(item.productId),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _OrderCategoryChip extends StatelessWidget {
  const _OrderCategoryChip({
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
            gradient: selected ? AppColors.goldGradient : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? AppColors.goldBorder
                : Border.all(color: const Color(0xff333333)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff1f1f1f),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductAccordion extends StatefulWidget {
  const _ProductAccordion({
    required this.item,
    required this.detail,
    required this.onExpand,
  });

  final OrderByProductItemModel item;
  final OrderByProductDetailModel? detail;
  final VoidCallback onExpand;

  @override
  State<_ProductAccordion> createState() => _ProductAccordionState();
}

class _ProductAccordionState extends State<_ProductAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffe7eaec),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _expanded = !_expanded);
              if (_expanded && widget.detail == null) widget.onExpand();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.item.imageUrl != null
                        ? Image.network(
                            widget.item.imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            color: AppColors.goldBorderColor,
                            child: const Icon(
                              Icons.bakery_dining_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Depo:${widget.item.quantity}  Eksik:${widget.item.total - widget.item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.item.total}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        widget.item.unit,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded && widget.detail != null) ...[
            const Divider(height: 1),
            ...widget.detail!.requests.map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.branchName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (r.note != null)
                            Text(
                              r.note!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${r.quantity} Tepsi',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
