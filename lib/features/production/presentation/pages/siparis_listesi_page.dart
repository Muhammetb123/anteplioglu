import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/di.dart';
import '../../../../core/widgets/gold_gradient_icon_button.dart';
import '../../data/models/order_model.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../logic/orders/orders_cubit.dart';
import '../../logic/orders/orders_state.dart';

@RoutePage()
class SiparisListesiPage extends StatelessWidget {
  const SiparisListesiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit(getIt<IOrderRepository>()),
      child: const _SiparisListesiView(),
    );
  }
}

class _SiparisListesiView extends StatefulWidget {
  const _SiparisListesiView();

  @override
  State<_SiparisListesiView> createState() => _SiparisListesiViewState();
}

class _SiparisListesiViewState extends State<_SiparisListesiView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<OrdersCubit>().loadOrdersByProduct();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      context.read<OrdersCubit>().loadOrdersByProduct();
    } else {
      context.read<OrdersCubit>().loadIncomingOrders();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
            onPressed: () => context.router.maybePop(),
          ),
        ),
        title: const Column(
          children: [
            Text(
              'Sipariş Listesi',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text('Tüm Siparişler', style: TextStyle(fontSize: 13)),
          ],
        ),
        centerTitle: true,
        actions: [
          GoldGradientIconButton(onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.mainColor,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: const Color(0xff888888),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                ),
                tabs: const [
                  Tab(text: 'Ürüne Göre'),
                  Tab(text: 'Şubeye Göre'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_UruneGoreTab(), _SubeyeGoreTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubeyeGoreTab extends StatelessWidget {
  const _SubeyeGoreTab();

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
                                    color: const Color(0xffc2a463),
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

class _UruneGoreTab extends StatefulWidget {
  const _UruneGoreTab();

  @override
  State<_UruneGoreTab> createState() => _UruneGoreTabState();
}

class _UruneGoreTabState extends State<_UruneGoreTab> {
  String? _selectedCategoryId;
  Map<String, String> _categoryNames = {};

  void _selectCategory(BuildContext context, String? id) {
    setState(() => _selectedCategoryId = id);
    context.read<OrdersCubit>().loadOrdersByProduct(categoryId: id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersByProductLoaded && state.categoryNames.isNotEmpty) {
          _categoryNames = state.categoryNames;
        }

        final isLoading = state is OrdersLoading;
        final loaded = state is OrdersByProductLoaded ? state : null;

        return Column(
          children: [
            if (_categoryNames.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _CategoryChip(
                      label: 'Tümü',
                      selected: _selectedCategoryId == null,
                      onTap: () => _selectCategory(context, null),
                    ),
                    ..._categoryNames.entries.map(
                      (e) => _CategoryChip(
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFBEAC4), Color(0xFFC2A463)],
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? const Color(0xffC2A463)
                  : const Color(0xff333333),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xff1f1f1f),
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
                            color: const Color(0xffc2a463),
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
