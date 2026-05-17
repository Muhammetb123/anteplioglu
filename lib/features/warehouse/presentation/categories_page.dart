import 'package:antepli/core/constants/app_colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/di.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/gold_gradient_icon_button.dart';
import '../../../core/network/api_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/general_text_form_field.dart';
import '../../admin/data/admin_repository.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/logic/auth_state.dart';
import '../../auth/models/branch.dart';
import '../data/warehouse_repository.dart';
import '../models/category.dart';
import '../models/product.dart';

enum _CategoryFilter { all, active, passive }

@RoutePage()
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _repo = getIt<WarehouseRepository>();
  final _adminRepo = getIt<AdminRepository>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  List<Category> _categories = const [];
  String _searchQuery = '';
  _CategoryFilter _filter = _CategoryFilter.all;
  AppDrawerMainSection _expandedDrawerSection = AppDrawerMainSection.warehouse;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.getCategoriesWithProducts();
      if (!mounted) return;
      setState(() => _categories = list);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Kategoriler yuklenemedi');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Category> _filteredCategories() {
    Iterable<Category> list = _categories;
    if (_filter == _CategoryFilter.active) {
      list = list.where((c) => c.isActive);
    } else if (_filter == _CategoryFilter.passive) {
      list = list.where((c) => !c.isActive);
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where(
        (c) =>
            c.name.tr.toLowerCase().contains(q) ||
            c.name.en.toLowerCase().contains(q) ||
            c.name.de.toLowerCase().contains(q) ||
            c.code.toLowerCase().contains(q),
      );
    }
    return list.toList();
  }

  int get _activeCount => _categories.where((c) => c.isActive).length;
  int get _passiveCount => _categories.where((c) => !c.isActive).length;
  int get _totalCount => _categories.length;

  void _onToggleCategory(Category category, bool value) {
    setState(() {
      _categories = _categories
          .map((c) => c.id == category.id ? c.copyWith(isActive: value) : c)
          .toList();
    });
    // TODO(api): Kategori isActive toggle endpoint entegrasyonu eklenecek.
  }

  Future<void> _onAddCategory() async {
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddCategorySheet(),
    );
    if (!mounted || name == null || name.isEmpty) return;
    // TODO(api): Yeni kategori olusturma endpoint entegrasyonu eklenecek.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$name" eklendi (UI). API entegrasyonu yapilacak.'),
      ),
    );
  }

  void _onEditCategory(Category category) {
    // TODO(api): Kategori duzenleme akisi eklenecek.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.name.tr} duzenleme akisi yakinda eklenecek.'),
      ),
    );
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

    try {
      final branches = await _adminRepo.getBranches();
      Branch? target;
      for (final b in branches) {
        if (b.code == branchCode) {
          target = b;
          break;
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
    if (title != 'Kategori') {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$title yakinda eklenecek')));
    }
  }

  Future<void> _onProductionDrawerSubItem(String title) async {
    await _switchToBranchContext(branchCode: 'production');
    if (!mounted) return;
    switch (title) {
      case 'Anasayfa':
        context.router.replace(const ProductionHomeRoute());
        return;
      case 'Siparis Yonetimi':
        context.router.replace(const SiparisListesiRoute());
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
            Text('Depo', style: const TextStyle(fontWeight: FontWeight.w700)),
            const Text('Kategori Yonetimi', style: TextStyle(fontSize: 16)),
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
        },
        onProductionTap: () async {
          await _switchToBranchContext(branchCode: 'production');
          if (!context.mounted) return;
          Navigator.of(context).maybePop();
          context.router.replace(const ProductionHomeRoute());
        },
        onWarehouseSubItemTap: (title) {
          _onWarehouseDrawerSubItem(title);
        },
        onProductionSubItemTap: (title) {
          _onProductionDrawerSubItem(title);
        },
        selectedWarehouseSubItem: kAppDrawerWarehouseKategoriTitle,
        selectedProductionSubItem: null,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: AppColors.goldBorder,
                    gradient: AppColors.goldGradient,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _onAddCategory,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Text(
                          'Kategori Ekle',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: GeneralTextFormField(
                controller: _searchCtrl,
                hintText: 'Kategori ara...',
                prefixIcon: Icons.search,
                onChanged: (v) =>
                    setState(() => _searchQuery = v.trim().toLowerCase()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  _filterTab(
                    label: 'Tumu($_totalCount)',
                    selected: _filter == _CategoryFilter.all,
                    onTap: () => setState(() => _filter = _CategoryFilter.all),
                  ),
                  const SizedBox(width: 10),
                  _filterTab(
                    label: 'Aktif($_activeCount)',
                    selected: _filter == _CategoryFilter.active,
                    onTap: () =>
                        setState(() => _filter = _CategoryFilter.active),
                  ),
                  const SizedBox(width: 10),
                  _filterTab(
                    label: 'Pasif($_passiveCount)',
                    selected: _filter == _CategoryFilter.passive,
                    onTap: () =>
                        setState(() => _filter = _CategoryFilter.passive),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _errorView()
                  : _buildCategoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xffd4bc72) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xffd4bc72), width: 1.4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : const Color(0xff5e5e5e),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
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

  Widget _buildCategoryList() {
    final list = _filteredCategories();
    if (list.isEmpty) {
      return const Center(child: Text('Kategori bulunamadi'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final category = list[index];
          return _CategoryCard(
            category: category,
            onToggle: (v) => _onToggleCategory(category, v),
            onEdit: () => _onEditCategory(category),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onToggle,
    required this.onEdit,
  });

  final Category category;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final products = category.products.take(3).toList();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffe7eaec),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.name.tr.isNotEmpty
                      ? category.name.tr
                      : category.code,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1f1f1f),
                  ),
                ),
              ),
              Switch(
                value: category.isActive,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xff2f7d3b),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xffb6bbc0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                splashRadius: 20,
              ),
            ],
          ),
          if (products.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < products.length; i++) ...[
                  Expanded(child: _ProductChip(product: products[i])),
                  if (i != products.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductChip extends StatelessWidget {
  const _ProductChip({required this.product});

  final Product product;

  Color _bgColor() {
    switch (product.stockLevel) {
      case ProductStockLevel.safe:
        return const Color(0xffb8d99a);
      case ProductStockLevel.warning:
        return const Color(0xffe6cc8a);
      case ProductStockLevel.critical:
        return const Color(0xfff0bdb5);
    }
  }

  String _quantityLabel() {
    final qty = product.quantity;
    final qtyStr = qty == qty.toInt() ? qty.toInt().toString() : qty.toString();
    final unitLabel = _displayUnit(product.unit);
    return '$qtyStr $unitLabel'.trim();
  }

  String _displayUnit(String code) {
    switch (code.toLowerCase()) {
      case 'kg':
        return 'Kg';
      case 'gr':
      case 'g':
        return 'Gr';
      case 'lt':
      case 'l':
        return 'Litre';
      case 'ml':
        return 'Ml';
      case 'package':
        return 'Paket';
      case 'box':
        return 'Kutu';
      case 'pcs':
      case 'piece':
        return 'Adet';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff444444),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _quantityLabel(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xff1d1d1d),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _ctrl = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Kategori adi zorunlu');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xffe9ebed),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Yeni Kategori Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Kategori Adi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GeneralTextFormField(
                controller: _ctrl,
                hintText: 'Kategori adi',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 92, 139, 129),
                  width: 1,
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    width: 140,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ekle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
