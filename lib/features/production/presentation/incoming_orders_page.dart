import 'package:antepli/core/constants/app_colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/di/di.dart';
import '../../../core/network/api_error.dart';
import '../../admin/data/admin_repository.dart';
import '../../auth/models/branch.dart';
import '../data/production_repository.dart';
import '../models/production_order.dart';

@RoutePage()
class IncomingOrdersPage extends StatefulWidget {
  const IncomingOrdersPage({super.key});

  @override
  State<IncomingOrdersPage> createState() => _IncomingOrdersPageState();
}

class _IncomingOrdersPageState extends State<IncomingOrdersPage> {
  final _repo = getIt<ProductionRepository>();
  final _adminRepo = getIt<AdminRepository>();

  bool _loading = false;
  String? _error;
  ProductionOrdersPage _page = ProductionOrdersPage.empty;
  Map<String, Branch> _branchById = const {};
  ProductionOrderStatus? _filter;

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
        _repo.getIncomingOrders(page: 1, limit: 10, status: _filter),
        _adminRepo.getBranches(),
      ]);
      if (!mounted) return;
      setState(() {
        _page = results[0] as ProductionOrdersPage;
        _branchById = {
          for (final b in results[1] as List<Branch>) b.id: b,
        };
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

  String _statusLabel(ProductionOrderStatus s) {
    switch (s) {
      case ProductionOrderStatus.draft:
        return 'Taslak';
      case ProductionOrderStatus.accepted:
        return 'Kabul Edildi';
      case ProductionOrderStatus.completed:
        return 'Tamamlandi';
      case ProductionOrderStatus.cancelled:
        return 'Iptal Edildi';
      case ProductionOrderStatus.unknown:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Tum Siparisler',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(label: 'Hepsi', value: null),
                    _filterChip(
                      label: _statusLabel(ProductionOrderStatus.draft),
                      value: ProductionOrderStatus.draft,
                    ),
                    _filterChip(
                      label: _statusLabel(ProductionOrderStatus.completed),
                      value: ProductionOrderStatus.completed,
                    ),
                    _filterChip(
                      label: _statusLabel(ProductionOrderStatus.cancelled),
                      value: ProductionOrderStatus.cancelled,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _page.items.isEmpty
                  ? const Center(child: Text('Siparis bulunamadi'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          MediaQuery.of(context).padding.bottom + 24,
                        ),
                        itemCount: _page.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final order = _page.items[index];
                          return _buildOrderCard(order);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required ProductionOrderStatus? value,
  }) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _filter = value);
          _load();
        },
        selectedColor: const Color(0xffd4bc72),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.black : const Color(0xff5e5e5e),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xffd4bc72)),
        ),
      ),
    );
  }

  Widget _buildOrderCard(ProductionOrder order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffe7eaec),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _branchName(order.fromBranchId),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                order.orderNumber.isEmpty ? '' : '#${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(order.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.items.length} kalem',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ProductionOrderStatus s) {
    switch (s) {
      case ProductionOrderStatus.draft:
        return const Color(0xff8a8a8a);
      case ProductionOrderStatus.accepted:
        return const Color(0xff2f7d3b);
      case ProductionOrderStatus.completed:
        return AppColors.mainColor;
      case ProductionOrderStatus.cancelled:
        return const Color(0xffc44a4a);
      case ProductionOrderStatus.unknown:
        return Colors.grey;
    }
  }
}
