import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../logic/orders/orders_cubit.dart';
import '../../logic/orders/orders_state.dart';

class SubeyeGoreTab extends StatelessWidget {
  const SubeyeGoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OrdersError) {
          return Center(child: Text(state.message));
        }
        if (state is! IncomingOrdersLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Sipariş no veya müşteri ara...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<OrdersCubit>().loadIncomingOrders(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final order = state.items[i];
                    return _BranchAccordion(
                      order: order,
                      branchNames: state.branchNames,
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

class _BranchAccordion extends StatefulWidget {
  const _BranchAccordion({required this.order, this.branchNames = const {}});

  final OrderModel order;
  final Map<String, String> branchNames;

  @override
  State<_BranchAccordion> createState() => _BranchAccordionState();
}

class _BranchAccordionState extends State<_BranchAccordion> {
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
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xff1f1f1f),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.branchNames[widget.order.fromBranchId] ??
                          widget.order.fromBranchName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '#${widget.order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.order.createdAt != null) ...[
                    Text(
                      '${widget.order.createdAt!.day.toString().padLeft(2, '0')}.${widget.order.createdAt!.month.toString().padLeft(2, '0')}.${widget.order.createdAt!.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...widget.order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child:
                                item.productImageUrl != null &&
                                    item.productImageUrl!.isNotEmpty
                                ? Image.network(
                                    item.productImageUrl!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 36,
                                    height: 36,
                                    color: AppColors.goldBorderColor,
                                    child: const Icon(
                                      Icons.bakery_dining_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.note != null && item.note!.isNotEmpty)
                                  Text(
                                    item.note!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.quantity} Tepsi',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
