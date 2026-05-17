import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/di.dart';
import '../../../../core/widgets/gold_gradient_icon_button.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../logic/orders/orders_cubit.dart';
import '../widgets/subeye_gore_tab.dart';
import '../widgets/urune_gore_tab.dart';

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
            isCircle: true,
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
              children: const [UruneGoreTab(), SubeyeGoreTab()],
            ),
          ),
        ],
      ),
    );
  }
}


