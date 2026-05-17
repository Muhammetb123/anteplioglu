import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/gold_gradient_icon_button.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import '../../../auth/models/branch.dart';
import '../../data/models/order_model.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../logic/orders/orders_cubit.dart';
import '../../logic/orders/orders_state.dart';

@RoutePage()
class ProductionHomePage extends StatelessWidget {
  const ProductionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit(getIt<IOrderRepository>())
        ..loadIncomingOrders(limit: 3),
      child: const _ProductionHomeView(),
    );
  }
}

class _ProductionHomeView extends StatefulWidget {
  const _ProductionHomeView();

  @override
  State<_ProductionHomeView> createState() => _ProductionHomeViewState();
}

class _ProductionHomeViewState extends State<_ProductionHomeView> {
  final _adminRepo = getIt<AdminRepository>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, Branch> _branchById = const {};
  AppDrawerMainSection _expandedSection = AppDrawerMainSection.production;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await _adminRepo.getBranches();
      if (!mounted) return;
      setState(() {
        _branchById = {for (final b in branches) b.id: b};
      });
    } catch (_) {}
  }

  String _branchName(String id) {
    final b = _branchById[id];
    if (b == null) return 'Şube';
    if (b.code == 'warehouse') return 'Depo';
    if (b.code == 'production') return 'Prodüksiyon';
    return b.name.isNotEmpty ? b.name : 'Şube';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  Future<void> _switchToAdminContext() async {
    final authState = context.read<AuthCubit>().state;
    final me = authState is AuthAuthenticated ? authState.user : null;
    final userId = me?.id;
    final roleId = me?.role?.id;
    if (userId == null || roleId == null) return;
    try {
      await _adminRepo.assignUserRoleAndBranch(
          userId: userId, roleId: roleId, branchId: null);
      if (!mounted) return;
      await context.read<AuthCubit>().refreshUser();
    } catch (_) {}
  }

  Future<void> _switchToBranchContext(String branchCode) async {
    final authState = context.read<AuthCubit>().state;
    final me = authState is AuthAuthenticated ? authState.user : null;
    final userId = me?.id;
    final roleId = me?.role?.id;
    if (userId == null || roleId == null) return;
    Branch? target = _branchById.values
        .where((b) => b.code == branchCode)
        .firstOrNull;
    if (target == null) {
      final list = await _adminRepo.getBranches();
      target = list.where((b) => b.code == branchCode).firstOrNull;
    }
    if (target == null) return;
    try {
      await _adminRepo.assignUserRoleAndBranch(
          userId: userId, roleId: roleId, branchId: target.id);
      if (!mounted) return;
      await context.read<AuthCubit>().refreshUser();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
        leading: const SizedBox.shrink(),
        centerTitle: true,
        title: const Column(
          children: [
            Text('Anasayfa',
                style: TextStyle(fontWeight: FontWeight.w700)),
            Text('Tüm Siparişler', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          GoldGradientIconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: AppDrawerBranch(
        expandedSection: _expandedSection,
        onToggleSection: (s) => setState(() => _expandedSection = s),
        onAdminTap: () async {
          await _switchToAdminContext();
          if (!context.mounted) return;
          Navigator.of(context).maybePop();
          context.router.replace(const AdminHomeRoute());
        },
        onWarehouseTap: () async {
          await _switchToBranchContext('warehouse');
          if (!context.mounted) return;
          Navigator.of(context).maybePop();
          context.router.replace(const CategoriesRoute());
        },
        onProductionTap: () async {
          await _switchToBranchContext('production');
          if (!context.mounted) return;
          Navigator.of(context).maybePop();
        },
        onWarehouseSubItemTap: (_) {},
        onProductionSubItemTap: (title) {
          switch (title) {
            case 'Anasayfa':
              Navigator.of(context).maybePop();
            case 'Siparis Yonetimi':
              Navigator.of(context).maybePop();
              context.router.push(const SiparisListesiRoute());
            case 'Urun Yonetimi':
              Navigator.of(context).maybePop();
              context.router.push(const UrunYonetimiRoute());
            case 'Raporlar':
              Navigator.of(context).maybePop();
              context.router.push(const RaporlamaRoute());
          }
        },
        selectedWarehouseSubItem: null,
        selectedProductionSubItem: kAppDrawerProductionAnasayfaTitle,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<OrdersCubit>().loadIncomingOrders(limit: 3),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).padding.bottom + 100,
          ),
          children: [
            _buildBanner(),
            const SizedBox(height: 18),
            _buildShortcuts(context),
            const SizedBox(height: 22),
            _buildRecentOrdersHeader(context),
            const SizedBox(height: 10),
            BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) {
                if (state is OrdersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is OrdersError) {
                  return Center(child: Text(state.message));
                }
                if (state is! IncomingOrdersLoaded || state.items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('Henüz sipariş bulunmuyor')),
                  );
                }
                return Column(
                  children: state.items
                      .map((o) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _OrderRow(
                              order: o,
                              branchName: _branchName(o.fromBranchId),
                              dateLabel: _formatDate(o.createdAt),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff8e8460), Color(0xff5a5037)],
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          'anteplioglu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildShortcuts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutCard(
            icon: Icons.list_alt_outlined,
            label: 'Ürün Listesi',
            onTap: () => context.router.push(const UrunYonetimiRoute()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShortcutCard(
            icon: Icons.kitchen_outlined,
            label: 'Ara Dolap',
            onTap: () => context.router.push(const UrunYonetimiRoute()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShortcutCard(
            icon: Icons.contact_page_outlined,
            label: 'Müşteri Listesi',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Son Siparişler',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xff1f1f1f)),
          ),
        ),
        GestureDetector(
          onTap: () => context.router.push(const SiparisListesiRoute()),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(
              'Tümünü Gör',
              style: TextStyle(
                color: AppColors.mainColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xffe7eaec),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.mainColor, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1f1f1f)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.order,
    required this.branchName,
    required this.dateLabel,
  });

  final OrderModel order;
  final String branchName;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffe7eaec),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xffc2a463),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.bakery_dining_outlined,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branchName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1f1f1f))),
                const SizedBox(height: 2),
                Text(dateLabel,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xff5e5e5e))),
              ],
            ),
          ),
          Text(
            order.orderNumber.isEmpty ? '' : '#${order.orderNumber}',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff1f1f1f)),
          ),
        ],
      ),
    );
  }
}
