import 'package:antepli/core/constants/app_colors.dart';
import 'package:antepli/core/widgets/gold_gradient_icon_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/di.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/network/api_error.dart';
import '../../../core/routing/app_router.dart';
import '../../admin/data/admin_repository.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/logic/auth_state.dart';
import '../../auth/models/branch.dart';
import '../data/production_repository.dart';
import '../models/production_order.dart';

@RoutePage()
class ProductionHomePage extends StatefulWidget {
  const ProductionHomePage({super.key});

  @override
  State<ProductionHomePage> createState() => _ProductionHomePageState();
}

class _ProductionHomePageState extends State<ProductionHomePage> {
  final _productionRepo = getIt<ProductionRepository>();
  final _adminRepo = getIt<AdminRepository>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = false;
  String? _error;
  List<ProductionOrder> _recentOrders = const [];
  Map<String, Branch> _branchById = const {};
  AppDrawerMainSection _expandedDrawerSection = AppDrawerMainSection.production;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _productionRepo.getIncomingOrders(page: 1, limit: 10),
        _adminRepo.getBranches(),
      ]);
      if (!mounted) return;
      final ordersPage = results[0] as ProductionOrdersPage;
      final branches = results[1] as List<Branch>;
      setState(() {
        _recentOrders = ordersPage.items.take(3).toList();
        _branchById = {for (final b in branches) b.id: b};
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Sipariler yuklenemedi');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _branchName(String id) {
    final b = _branchById[id];
    if (b == null) return 'Sube';
    if (b.code == 'warehouse') return 'Depo';
    if (b.code == 'production') return 'Produksiyon';
    return b.name.isNotEmpty ? b.name : 'Sube';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  void _toggleDrawerSection(AppDrawerMainSection section) {
    setState(() {
      _expandedDrawerSection = section;
    });
  }

  Future<void> _switchToAdminContext() async {
    final authState = context.read<AuthCubit>().state;
    final me = authState is AuthAuthenticated ? authState.user : null;
    final roleId = me?.role?.id;
    final userId = me?.id;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanici bilgisi bulunamadi')),
      );
      return;
    }
    if (roleId == null || roleId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rol bilgisi bulunamadi')));
      return;
    }

    try {
      await _adminRepo.assignUserRoleAndBranch(
        userId: userId,
        roleId: roleId,
        branchId: null,
      );
      if (!mounted) return;
      await context.read<AuthCubit>().refreshUser();
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Admin şubesi secilemedi')));
    }
  }

  Future<void> _switchToBranchContext({required String branchCode}) async {
    final authState = context.read<AuthCubit>().state;
    final me = authState is AuthAuthenticated ? authState.user : null;
    final roleId = me?.role?.id;
    final userId = me?.id;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanici bilgisi bulunamadi')),
      );
      return;
    }
    if (roleId == null || roleId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rol bilgisi bulunamadi')));
      return;
    }

    Branch? target;
    for (final b in _branchById.values) {
      if (b.code == branchCode) {
        target = b;
        break;
      }
    }

    try {
      if (target == null) {
        final branches = await _adminRepo.getBranches();
        for (final b in branches) {
          if (b.code == branchCode) {
            target = b;
            break;
          }
        }
      }
      if (target == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$branchCode" şube bilgisi bulunamadi')),
        );
        return;
      }
      await _adminRepo.assignUserRoleAndBranch(
        userId: userId,
        roleId: roleId,
        branchId: target.id,
      );
      if (!mounted) return;
      await context.read<AuthCubit>().refreshUser();
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Şube secilemedi')));
    }
  }

  Future<void> _onWarehouseDrawerSubItem(String title) async {
    await _switchToBranchContext(branchCode: 'warehouse');
    if (!mounted) return;
    switch (title) {
      case 'Kategori':
        context.router.replace(const CategoriesRoute());
        return;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title yakinda eklenecek')));
    }
  }

  void _onProductionDrawerSubItem(String title) {
    switch (title) {
      case 'Anasayfa':
        return;
      case 'Siparis Yonetimi':
        context.router.replace(const IncomingOrdersRoute());
        return;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title yakinda eklenecek')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
        leading: SizedBox.shrink(),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Produksiyon',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const Text('Tum Siparisler', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
           GoldGradientIconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: AppDrawerBranch(
        expandedSection: _expandedDrawerSection,
        onToggleSection: _toggleDrawerSection,
        onAdminTap: () async {
          await _switchToAdminContext();
          if (!context.mounted) return;
          Navigator.of(context).maybePop();
          context.router.replace(const AdminHomeRoute());
        },
        onWarehouseTap: () async {
          await _switchToBranchContext(branchCode: 'warehouse');
          if (!context.mounted) return;
          Navigator.of(context).maybePop();
          context.router.replace(const CategoriesRoute());
        },
        onProductionTap: () async {
          await _switchToBranchContext(branchCode: 'production');
          if (!context.mounted) return;
          Navigator.of(context).maybePop();
        },
        onWarehouseSubItemTap: (title) {
          _onWarehouseDrawerSubItem(title);
        },
        onProductionSubItemTap: _onProductionDrawerSubItem,
        selectedWarehouseSubItem: null,
        selectedProductionSubItem: kAppDrawerProductionAnasayfaTitle,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorView()
          : RefreshIndicator(
              onRefresh: _load,
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
                  _buildShortcuts(),
                  const SizedBox(height: 22),
                  _buildRecentOrdersHeader(),
                  const SizedBox(height: 10),
                  if (_recentOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      alignment: Alignment.center,
                      child: const Text('Henuz siparis bulunmuyor'),
                    )
                  else
                    ..._recentOrders.map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _OrderRow(
                          order: o,
                          branchName: _branchName(o.fromBranchId),
                          dateLabel: _formatDate(o.createdAt),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'Bir hata olustu', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Tekrar dene')),
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

  Widget _buildShortcuts() {
    return Row(
      children: [
        Expanded(
          child: _ShortcutCard(
            icon: Icons.list_alt_outlined,
            label: 'Urun Listesi',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShortcutCard(
            icon: Icons.kitchen_outlined,
            label: 'Ara Dolap',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShortcutCard(
            icon: Icons.contact_page_outlined,
            label: 'Musteri Listesi',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Son Siparisler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff1f1f1f),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            context.router.push(const IncomingOrdersRoute());
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(
              'Tumunu Gor',
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
                color: Color(0xff1f1f1f),
              ),
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

  final ProductionOrder order;
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
            child: const Icon(
              Icons.bakery_dining_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branchName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1f1f1f),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff5e5e5e),
                  ),
                ),
              ],
            ),
          ),
          Text(
            order.orderNumber.isEmpty ? '' : '#${order.orderNumber}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xff1f1f1f),
            ),
          ),
        ],
      ),
    );
  }
}
