import 'package:antepli/core/constants/app_colors.dart';
import 'package:antepli/core/utils.dart';
import 'package:antepli/core/widgets/app_drawer.dart';
import 'package:antepli/core/widgets/general_button.dart';
import 'package:antepli/core/widgets/general_text_form_field.dart';
import 'package:antepli/core/widgets/gold_gradient_icon_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/di.dart';
import '../../../core/network/api_error.dart';
import '../../../core/routing/app_router.dart';
import '../../admin/data/admin_repository.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/logic/auth_state.dart';
import '../../auth/models/branch.dart';
import '../../auth/models/role.dart';
import '../../auth/models/user.dart';

enum _AdminSection { users, personnel, departments }

@RoutePage()
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  static const String _allBranchesValue = '__all_branches__';
  static const String _allRolesValue = '__all_roles__';

  final _repo = getIt<AdminRepository>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtrl = TextEditingController();

  _AdminSection _section = _AdminSection.users;
  String _searchQuery = '';
  String _departmentSearch = '';
  String? _selectedRoleId;
  String? _selectedBranchId;
  bool _loading = false;
  String? _error;
  List<Role> _roles = const [];
  List<Branch> _branches = const [];
  List<User> _users = const [];
  AppDrawerMainSection _expandedDrawerSection = AppDrawerMainSection.admin;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rolesFuture = _repo.getRoles();
      final branchesFuture = _repo.getBranches();
      final usersFuture = _repo.getUsers(page: 1, limit: 10);
      final results = await Future.wait([
        rolesFuture,
        branchesFuture,
        usersFuture,
      ]);
      if (!mounted) return;
      setState(() {
        _roles = results[0] as List<Role>;
        _branches = results[1] as List<Branch>;
        _users = (results[2] as AdminUsersResponse).items;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Veriler yuklenemedi');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.getUsers(
        page: 1,
        limit: 10,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        roleId: _section == _AdminSection.personnel ? _selectedRoleId : null,
        branchId: _section == _AdminSection.personnel
            ? _selectedBranchId
            : null,
      );
      if (!mounted) return;
      setState(() => _users = res.items);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Kullanicilar yuklenemedi');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearchSubmit() {
    final text = _searchCtrl.text.trim();
    if (_section == _AdminSection.departments) {
      setState(() => _departmentSearch = text.toLowerCase());
      return;
    }
    _searchQuery = text;
    _loadUsers();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    if (_section == _AdminSection.departments) {
      setState(() => _departmentSearch = '');
      return;
    }
    setState(() => _searchQuery = '');
    _loadUsers();
  }

  void _changeSection(_AdminSection section) {
    setState(() {
      _section = section;
      _searchCtrl.clear();
      _searchQuery = '';
      _departmentSearch = '';
      if (section != _AdminSection.personnel) {
        _selectedRoleId = null;
        _selectedBranchId = null;
      }
    });
    if (section != _AdminSection.departments) {
      _loadUsers();
    }
  }

  String _subtitle() {
    switch (_section) {
      case _AdminSection.users:
        return 'Kullanicilar';
      case _AdminSection.personnel:
        return 'Personeller';
      case _AdminSection.departments:
        return 'Birimler';
    }
  }

  bool _isDrawerSectionExpanded(AppDrawerMainSection section) {
    return _expandedDrawerSection == section;
  }

  void _toggleDrawerSection(AppDrawerMainSection section) {
    setState(() {
      _expandedDrawerSection = section;
    });
  }

  Branch? _findBranchByCode(String code) {
    for (final b in _branches) {
      if (b.code == code) return b;
    }
    return null;
  }

  Future<void> _onDrawerWarehouseTap() async {
    final wasExpanded = _isDrawerSectionExpanded(
      AppDrawerMainSection.warehouse,
    );
    setState(() {
      _expandedDrawerSection = AppDrawerMainSection.warehouse;
    });

    if (!wasExpanded) {
      await _switchAdminContext(branchCode: 'warehouse');
    }

    if (!mounted) return;
    Navigator.of(context).maybePop();
    context.router.replace(const CategoriesRoute());
  }

  Future<void> _onDrawerProductionTap() async {
    final wasExpanded = _isDrawerSectionExpanded(
      AppDrawerMainSection.production,
    );
    setState(() {
      _expandedDrawerSection = AppDrawerMainSection.production;
    });

    if (!wasExpanded) {
      await _switchAdminContext(branchCode: 'production');
    }

    if (!mounted) return;
    Navigator.of(context).maybePop();
    context.router.replace(const ProductionHomeRoute());
  }

  Future<void> _onWarehouseSubDrawerItem(String title) async {
    await _switchAdminContext(branchCode: 'warehouse');
    if (!mounted) return;
    switch (title) {
      case 'Kategori':
        context.router.replace(const CategoriesRoute());
        return;
      default:
        Utils.showSnackBar('$title yakinda eklenecek', Colors.deepOrange);
    }
  }

  Future<void> _onProductionSubDrawerItem(String title) async {
    await _switchAdminContext(branchCode: 'production');
    if (!mounted) return;
    switch (title) {
      case 'Anasayfa':
        context.router.replace(const ProductionHomeRoute());
        return;
      case 'Siparis Yonetimi':
        context.router.replace(const IncomingOrdersRoute());
        return;
      default:
        Utils.showSnackBar('$title yakinda eklenecek', Colors.deepOrange);
    }
  }

  Future<void> _switchAdminContext({required String branchCode}) async {
    final authState = context.read<AuthCubit>().state;
    final me = authState is AuthAuthenticated ? authState.user : null;
    final roleId = me?.role?.id;
    final userId = me?.id;
    final branch = _findBranchByCode(branchCode);

    if (userId == null || userId.isEmpty) {
      Utils.showSnackBar('Kullanici bilgisi bulunamadi', Colors.red);
      return;
    }
    if (roleId == null || roleId.isEmpty) {
      Utils.showSnackBar('Admin rol bilgisi bulunamadi', Colors.red);
      return;
    }
    if (branch == null) {
      Utils.showSnackBar('"$branchCode" birim bilgisi bulunamadi', Colors.red);
      return;
    }

    if (branchCode == 'production') {
      debugPrint('Production branchId: ${branch.id}');
    }

    try {
      await _repo.assignUserRoleAndBranch(
        userId: userId,
        roleId: roleId,
        branchId: branch.id,
      );
      if (!mounted) return;
      await context.read<AuthCubit>().refreshUser();
    } on ApiError catch (e) {
      if (!mounted) return;
      Utils.showSnackBar(e.message, Colors.red);
    } catch (_) {
      if (!mounted) return;
      Utils.showSnackBar('Birim degistirilemedi', Colors.red);
    }
  }

  String _displayBranchName(Branch branch) {
    if (branch.code == 'warehouse') return 'Depo';
    if (branch.code == 'production') return 'Produksiyon';
    return branch.name;
  }

  List<Branch> _departmentItems() {
    final all = List<Branch>.from(_branches);
    all.sort((a, b) {
      int rank(String code) {
        if (code == 'warehouse') return 0;
        if (code == 'production') return 1;
        return 2;
      }

      final rankCompare = rank(a.code).compareTo(rank(b.code));
      if (rankCompare != 0) return rankCompare;
      return _displayBranchName(a).compareTo(_displayBranchName(b));
    });
    if (_departmentSearch.isEmpty) return all;
    return all
        .where(
          (e) =>
              _displayBranchName(e).toLowerCase().contains(_departmentSearch),
        )
        .toList();
  }

  String _initials(User user) {
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';
    final v = '$first$last'.trim();
    return v.isEmpty ? '??' : v.toUpperCase();
  }

  Future<void> _showPersonnelEmailDialog(User user) async {
    final platform = Theme.of(context).platform;
    final useCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (useCupertino) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('${user.firstName} ${user.lastName}'),
          content: Text(user.email),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstName} ${user.lastName}'),
        content: Text(user.email),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDepartmentBottomSheet() async {
    final createdBranch = await showModalBottomSheet<Branch>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddDepartmentSheet(repo: _repo),
    );
    if (!mounted || createdBranch == null) return;

    setState(() {
      _branches = [createdBranch, ..._branches];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${createdBranch.name} birimi eklendi')),
    );
  }

  Future<void> _showEditDepartmentBottomSheet(Branch branch) async {
    final updated = await showModalBottomSheet<Branch>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditDepartmentSheet(repo: _repo, branch: branch),
    );
    if (!mounted || updated == null) return;

    setState(() {
      _branches = [
        for (final b in _branches)
          if (b.id == updated.id) updated else b,
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${updated.name} birimi guncellendi')),
    );
  }

  Future<void> _showAssignRoleBranchBottomSheet(User user) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignRoleBranchSheet(
        repo: _repo,
        user: user,
        branches: _branches,
        roles: _roles,
        displayBranchName: _displayBranchName,
      ),
    );
    if (!mounted || saved != true) return;

    await _loadUsers();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${user.firstName} ${user.lastName} icin rol ve birim guncellendi',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final me = authState is AuthAuthenticated ? authState.user : null;
    final departments = _departmentItems();
    final showAddDepartmentFab = _section == _AdminSection.departments;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
        leading: SizedBox.shrink(),
        centerTitle: true,
        title: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(_subtitle(), style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          GoldGradientIconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: AppDrawerAdmin(
        expandedSection: _expandedDrawerSection,
        onAdminHeaderTap: () =>
            _toggleDrawerSection(AppDrawerMainSection.admin),
        adminSectionChildren: [
          _drawerItem('Kullanicilar', _AdminSection.users),
          _drawerItem('Personeller', _AdminSection.personnel),
          _drawerItem('Birimler', _AdminSection.departments),
        ],
        onWarehouseHeaderTap: _onDrawerWarehouseTap,
        onProductionHeaderTap: _onDrawerProductionTap,
        onWarehouseSubItemTap: (title) {
          _onWarehouseSubDrawerItem(title);
        },
        onProductionSubItemTap: (title) {
          _onProductionSubDrawerItem(title);
        },
        footer: me == null
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${me.firstName} ${me.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            me.role?.name ?? '',
                            style: const TextStyle(color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<AuthCubit>().signOut();
                        context.router.maybePop();
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                ),
              ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GeneralTextFormField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSearchSubmit(),
              onChanged: (_) => setState(() {}),
              hintText: _section == _AdminSection.departments
                  ? 'Birim ara...'
                  : _section == _AdminSection.personnel
                  ? 'Personel ara...'
                  : 'Kullanici ara...',
              prefixIcon: Icons.search,
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear, color: Color(0xff8a9aa5)),
                      splashRadius: 22,
                    )
                  : null,
            ),
          ),
          if (_section == _AdminSection.personnel)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _filterPopupField(
                        label: _selectedBranchLabel(),
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: _allBranchesValue,
                            child: Text('Birim'),
                          ),
                          ..._branches.map(
                            (e) => PopupMenuItem<String>(
                              value: e.id,
                              child: Text(_displayBranchName(e)),
                            ),
                          ),
                        ],
                        onSelected: (v) {
                          setState(
                            () => _selectedBranchId = v == _allBranchesValue
                                ? null
                                : v,
                          );
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _filterPopupField(
                        label: _selectedRoleLabel(),
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: _allRolesValue,
                            child: Text('Rol'),
                          ),
                          ..._roles.map(
                            (e) => PopupMenuItem<String>(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          ),
                        ],
                        onSelected: (v) {
                          setState(
                            () => _selectedRoleId = v == _allRolesValue
                                ? null
                                : v,
                          );
                          _loadUsers();
                        },
                      ),
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
                : _section == _AdminSection.departments
                ? _departmentsList(departments)
                : _usersList(),
          ),
        ],
      ),
      floatingActionButton: showAddDepartmentFab
          ? GeneralButton(
              text: 'Birim ekle',
              onPressed: _showAddDepartmentBottomSheet,
              variant: GeneralButtonVariant.gold,
            )
          : null,
    );
  }

  Widget _usersList() {
    if (_users.isEmpty) {
      return const Center(child: Text('Kayit bulunamadi'));
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + 80,
      ),
      itemCount: _users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = _users[index];
        return InkWell(
          onTap: _section == _AdminSection.personnel
              ? () => _showPersonnelEmailDialog(user)
              : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffe7eaec),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _initials(user),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}'.trim(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff2d2d2d),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (_section == _AdminSection.personnel)
                        Text(
                          user.branch == null
                              ? ''
                              : _displayBranchName(user.branch!),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        )
                      else
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_section == _AdminSection.personnel)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        user.role?.name ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(''),
                    ],
                  )
                else
                  IconButton(
                    onPressed: () => _showAssignRoleBranchBottomSheet(user),
                    icon: const Icon(Icons.more_vert),
                    splashRadius: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _departmentsList(List<Branch> departments) {
    if (departments.isEmpty) {
      return const Center(child: Text('Birim bulunamadi'));
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + 80,
      ),
      itemCount: departments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 4, 2, 4),
          decoration: BoxDecoration(
            color: departments[index].isActive
                ? AppColors.activeSwitchColor.withValues(alpha: 0.1)
                : const Color(0xffe7eaec).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _displayBranchName(departments[index]),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                // TODO buraya createdAt tarih eklenecek
                '',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    _showEditDepartmentBottomSheet(departments[index]),
                icon: const Icon(Icons.more_vert),
                splashRadius: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerItem(String title, _AdminSection section) {
    final selected = _section == section;
    return InkWell(
      onTap: () {
        Navigator.of(context).maybePop();
        _changeSection(section);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.chevron_right : Icons.chevron_right_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _selectedBranchLabel() {
    if (_selectedBranchId == null) return 'Birim';
    for (final branch in _branches) {
      if (branch.id == _selectedBranchId) {
        return _displayBranchName(branch);
      }
    }
    return 'Birim';
  }

  String _selectedRoleLabel() {
    if (_selectedRoleId == null) return 'Rol';
    for (final role in _roles) {
      if (role.id == _selectedRoleId) {
        return role.name;
      }
    }
    return 'Rol';
  }

  Widget _filterPopupField({
    required String label,
    required List<PopupMenuEntry<String>> Function(BuildContext) itemBuilder,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff8a8a8a)),
      ),
      child: PopupMenuButton<String>(
        tooltip: '',
        position: PopupMenuPosition.under,
        onSelected: onSelected,
        itemBuilder: itemBuilder,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditDepartmentSheet extends StatefulWidget {
  const _EditDepartmentSheet({required this.repo, required this.branch});

  final AdminRepository repo;
  final Branch branch;

  @override
  State<_EditDepartmentSheet> createState() => _EditDepartmentSheetState();
}

class _EditDepartmentSheetState extends State<_EditDepartmentSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final bool _codeLocked;
  late int _level;
  late bool _isActive;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final b = widget.branch;
    _nameCtrl = TextEditingController(text: b.name);
    _codeCtrl = TextEditingController(text: b.code);
    _codeLocked = b.code.trim().isNotEmpty;
    _level = _levelFromApi(b.level);
    _isActive = b.isActive;
  }

  static int _levelFromApi(String level) {
    switch (level.trim()) {
      case 'level_1':
        return 1;
      case 'level_2':
        return 2;
      case 'level_3':
        return 3;
      default:
        return 1;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Birim adi zorunlu');
      return;
    }

    final code = _codeLocked
        ? widget.branch.code.trim()
        : _codeCtrl.text.trim();

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      final updated = await widget.repo.updateBranch(
        id: widget.branch.id,
        name: name,
        code: code,
        level: 'level_$_level',
        isActive: _isActive,
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'Birim guncellenirken hata olustu');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
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
        child: SingleChildScrollView(
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
                        'Birimi Duzenle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 30),
                      splashRadius: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Birim Adi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GeneralTextFormField(
                  controller: _nameCtrl,
                  enabled: !_submitting,
                  textInputAction: TextInputAction.next,
                  hintText: 'Birimin adi',
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 92, 139, 129),
                    width: 1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kod',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GeneralTextFormField(
                  controller: _codeCtrl,
                  enabled: !_submitting && !_codeLocked,
                  textInputAction: TextInputAction.next,
                  hintText: 'Birim kodu',
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 92, 139, 129),
                    width: 1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seviye',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _levelDropdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Aktif',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: _submitting
                          ? null
                          : (v) => setState(() => _isActive = v),
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xff2f7d3b),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xffb6bbc0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Spacer(),
                    GeneralButton(
                      text: 'Kaydet',
                      width: 140,
                      variant: GeneralButtonVariant.green,
                      isLoading: _submitting,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _levelDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffdde1e3),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _level,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          borderRadius: BorderRadius.circular(12),
          items: const [
            DropdownMenuItem(value: 1, child: Text('1')),
            DropdownMenuItem(value: 2, child: Text('2')),
            DropdownMenuItem(value: 3, child: Text('3')),
          ],
          onChanged: _submitting
              ? null
              : (v) {
                  if (v != null) setState(() => _level = v);
                },
        ),
      ),
    );
  }
}

class _AddDepartmentSheet extends StatefulWidget {
  const _AddDepartmentSheet({required this.repo});

  final AdminRepository repo;

  @override
  State<_AddDepartmentSheet> createState() => _AddDepartmentSheetState();
}

class _AssignRoleBranchSheet extends StatefulWidget {
  const _AssignRoleBranchSheet({
    required this.repo,
    required this.user,
    required this.branches,
    required this.roles,
    required this.displayBranchName,
  });

  final AdminRepository repo;
  final User user;
  final List<Branch> branches;
  final List<Role> roles;
  final String Function(Branch branch) displayBranchName;

  @override
  State<_AssignRoleBranchSheet> createState() => _AssignRoleBranchSheetState();
}

class _AssignRoleBranchSheetState extends State<_AssignRoleBranchSheet> {
  String? _selectedBranchId;
  String? _selectedRoleId;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.user.branch?.id;
    _selectedRoleId = widget.user.role?.id;
  }

  Future<void> _submit() async {
    if (_selectedBranchId == null || _selectedRoleId == null) {
      setState(() => _errorText = 'Lutfen birim ve rol secin');
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await widget.repo.assignUserRoleAndBranch(
        userId: widget.user.id,
        roleId: _selectedRoleId!,
        branchId: _selectedBranchId!,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'Rol atama sirasinda hata olustu');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
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
                      'Kullanicilar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff1f1f1f),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 24),
                    splashRadius: 22,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Birim Ekle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _sheetDropdown(
                value: _selectedBranchId,
                hint: 'Birim Secin',
                enabled: !_submitting,
                items: widget.branches
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.id,
                        child: Text(widget.displayBranchName(e)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedBranchId = v),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rol Ekle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _sheetDropdown(
                value: _selectedRoleId,
                hint: 'Rol secin',
                enabled: !_submitting,
                items: widget.roles
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedRoleId = v),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
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
                  GeneralButton(
                    text: 'Kaydet',
                    width: 140,
                    variant: GeneralButtonVariant.green,
                    isLoading: _submitting,
                    onPressed: _submitting ? null : _submit,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetDropdown({
    required String? value,
    required String hint,
    required bool enabled,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffdde1e3),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Color(0xff8a9aa5))),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          borderRadius: BorderRadius.circular(12),
          items: items,
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

class _AddDepartmentSheetState extends State<_AddDepartmentSheet> {
  final _nameCtrl = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Birim adi zorunlu');
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      final branch = await widget.repo.createBranch(name: name);
      if (!mounted) return;
      Navigator.of(context).pop(branch);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'Birim eklenirken hata olustu');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
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
                      'Yeni Birim Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 30),
                    splashRadius: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Birim Adi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GeneralTextFormField(
                controller: _nameCtrl,
                enabled: !_submitting,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                hintText: 'Birimin adi',
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
              const SizedBox(height: 22),
              Row(
                children: [
                  const Spacer(),
                  GeneralButton(
                    text: 'Ekle',
                    width: 140,
                    variant: GeneralButtonVariant.green,
                    isLoading: _submitting,
                    onPressed: _submitting ? null : _submit,
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
