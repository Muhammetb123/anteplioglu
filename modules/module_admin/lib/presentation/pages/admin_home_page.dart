import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_utils/shared_utils.dart';
import 'package:module_auth/module_auth.dart';

import '../../data/admin_repository.dart';
import '../../logic/paginated_users_cubit.dart';
import '../../logic/paginated_users_state.dart';

enum _AdminSection { users, personnel, customers, branches }

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
  final _navigator = getIt<AuthNavigator>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtrl = TextEditingController();
  final _usersScrollController = ScrollController();
  final _personnelScrollController = ScrollController();
  final _customersScrollController = ScrollController();

  _AdminSection _section = _AdminSection.users;
  String _departmentSearch = '';
  String? _selectedRoleId;
  String? _selectedBranchId;
  bool _loading = false;
  String? _error;
  List<Role> _roles = const [];
  Role? _customerRole;
  List<Branch> _branches = const [];
  List<Branch> _departmentBranches = const [];
  late final PaginatedUsersCubit _usersCubit;
  late final PaginatedUsersCubit _personnelCubit;
  late final PaginatedUsersCubit _customersCubit;
  AppDrawerMainSection _expandedDrawerSection = AppDrawerMainSection.admin;

  @override
  void initState() {
    super.initState();
    _usersCubit = PaginatedUsersCubit(
      repository: _repo,
      isPersonel: false,
      userFilter: (user) => !_isCustomerUser(user),
    );
    _personnelCubit = PaginatedUsersCubit(repository: _repo, isPersonel: true);
    _customersCubit = PaginatedUsersCubit(
      repository: _repo,
      isPersonel: false,
      userFilter: _isCustomerUser,
    );
    _usersScrollController.addListener(_onUsersScroll);
    _personnelScrollController.addListener(_onPersonnelScroll);
    _customersScrollController.addListener(_onCustomersScroll);
    _bootstrap();
  }

  @override
  void dispose() {
    _usersScrollController
      ..removeListener(_onUsersScroll)
      ..dispose();
    _personnelScrollController
      ..removeListener(_onPersonnelScroll)
      ..dispose();
    _customersScrollController
      ..removeListener(_onCustomersScroll)
      ..dispose();
    _usersCubit.close();
    _personnelCubit.close();
    _customersCubit.close();
    _searchCtrl.dispose();
    super.dispose();
  }

  static bool _isCustomerUser(User user) => user.role?.code == 'customer';

  PaginatedUsersCubit get _activeUsersCubit {
    switch (_section) {
      case _AdminSection.users:
        return _usersCubit;
      case _AdminSection.personnel:
        return _personnelCubit;
      case _AdminSection.customers:
        return _customersCubit;
      case _AdminSection.branches:
        return _usersCubit;
    }
  }

  ScrollController get _activeUsersScrollController {
    switch (_section) {
      case _AdminSection.users:
        return _usersScrollController;
      case _AdminSection.personnel:
        return _personnelScrollController;
      case _AdminSection.customers:
        return _customersScrollController;
      case _AdminSection.branches:
        return _usersScrollController;
    }
  }

  void _onUsersScroll() {
    if (_usersScrollController.position.pixels >=
        _usersScrollController.position.maxScrollExtent - 200) {
      _usersCubit.loadMore();
    }
  }

  void _onPersonnelScroll() {
    if (_personnelScrollController.position.pixels >=
        _personnelScrollController.position.maxScrollExtent - 200) {
      _personnelCubit.loadMore();
    }
  }

  void _onCustomersScroll() {
    if (_customersScrollController.position.pixels >=
        _customersScrollController.position.maxScrollExtent - 200) {
      _customersCubit.loadMore();
    }
  }

  Future<void> _refreshCurrentUserList() async {
    if (_section == _AdminSection.branches) return;
    await _activeUsersCubit.loadInitial();
  }

  Future<void> _applyPersonnelFilters() async {
    await _personnelCubit.updateFilters(
      isPersonel: true,
      roleId: _selectedRoleId,
      branchId: _selectedBranchId,
      search: _searchCtrl.text.trim(),
    );
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rolesFuture = _repo.getRoles();
      final branchesFuture = _repo.getBranches();
      final departmentBranchesFuture = _repo.getBranches(type: 'branch');
      final results = await Future.wait([
        rolesFuture,
        branchesFuture,
        departmentBranchesFuture,
      ]);
      if (!mounted) return;
      final allRoles = results[0] as List<Role>;
      final customerRoles = allRoles.where((r) => r.code == 'customer');
      final customerRole = customerRoles.isEmpty ? null : customerRoles.first;

      if (!mounted) return;
      setState(() {
        _roles = allRoles.where((r) => r.code != 'customer').toList();
        _customerRole = customerRole;
        _branches = results[1] as List<Branch>;
        _departmentBranches = results[2] as List<Branch>;
      });
      await _usersCubit.loadInitial();
      await _personnelCubit.updateFilters(isPersonel: true, reload: true);
      await _customersCubit.updateFilters(
        isPersonel: false,
        roleId: customerRole?.id,
        reload: true,
      );
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

  void _onSearchSubmit() {
    final text = _searchCtrl.text.trim();
    if (_section == _AdminSection.branches) {
      setState(() => _departmentSearch = text.toLowerCase());
      return;
    }
    if (_section == _AdminSection.personnel) {
      _applyPersonnelFilters();
      return;
    }
    _activeUsersCubit.updateFilters(
      isPersonel: _section == _AdminSection.personnel,
      roleId: _section == _AdminSection.customers ? _customerRole?.id : null,
      search: text,
    );
  }

  void _clearSearch() {
    _searchCtrl.clear();
    if (_section == _AdminSection.branches) {
      setState(() => _departmentSearch = '');
      return;
    }
    if (_section == _AdminSection.personnel) {
      _applyPersonnelFilters();
      return;
    }
    _activeUsersCubit.updateFilters(
      isPersonel: _section == _AdminSection.personnel,
      roleId: _section == _AdminSection.customers ? _customerRole?.id : null,
      search: null,
    );
  }

  void _changeSection(_AdminSection section) {
    setState(() {
      _section = section;
      _searchCtrl.clear();
      _departmentSearch = '';
      if (section != _AdminSection.personnel) {
        _selectedRoleId = null;
        _selectedBranchId = null;
      }
    });
    if (section == _AdminSection.branches) {
      _loadDepartmentBranches();
      return;
    }
    if (section == _AdminSection.personnel) {
      _applyPersonnelFilters();
      return;
    }
    _activeUsersCubit.updateFilters(
      isPersonel: section == _AdminSection.personnel,
      roleId: section == _AdminSection.customers ? _customerRole?.id : null,
      search: null,
    );
  }

  String _subtitle() {
    switch (_section) {
      case _AdminSection.users:
        return 'Kullanicilar';
      case _AdminSection.personnel:
        return 'Personeller';
      case _AdminSection.customers:
        return 'Musteriler';
      case _AdminSection.branches:
        return 'Şubeler';
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
    _navigator.navigateToCategories(context);
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
    _navigator.navigateToProductionHome(context);
  }

  Future<void> _onWarehouseSubDrawerItem(String title) async {
    await _switchAdminContext(branchCode: 'warehouse');
    if (!mounted) return;
    switch (title) {
      case 'Kategori':
        _navigator.navigateToCategories(context);
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
        _navigator.navigateToProductionHome(context);
        return;
      case 'Siparis Yonetimi':
        _navigator.navigateToOrderList(context);
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
      Utils.showSnackBar('"$branchCode" şube bilgisi bulunamadi', Colors.red);
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
      Utils.showSnackBar('Şube degistirilemedi', Colors.red);
    }
  }

  String _displayBranchName(Branch branch) {
    if (branch.code == 'warehouse') return 'Depo';
    if (branch.code == 'production') return 'Produksiyon';
    return branch.name;
  }

  List<Branch> _departmentItems() {
    final all = List<Branch>.from(_departmentBranches);
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

  Future<void> _loadDepartmentBranches() async {
    try {
      final list = await _repo.getBranches(type: 'branch');
      if (!mounted) return;
      setState(() => _departmentBranches = list);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Şubeler yuklenemedi');
    }
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
      _departmentBranches = [createdBranch, ..._departmentBranches];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${createdBranch.name} şubesi eklendi')),
    );
  }

  Future<void> _showAddCustomerBottomSheet() async {
    final customerRole = _customerRole;
    if (customerRole == null) {
      Utils.showSnackBar('Musteri rolu bulunamadi', Colors.red);
      return;
    }

    final addedUser = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCustomerSheet(
        repo: _repo,
        customerRole: customerRole,
        initials: _initials,
      ),
    );
    if (!mounted || addedUser == null) return;

    await _customersCubit.loadInitial();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${addedUser.firstName} ${addedUser.lastName} musteri olarak eklendi',
        ),
      ),
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
      _departmentBranches = [
        for (final b in _departmentBranches)
          if (b.id == updated.id) updated else b,
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${updated.name} şubesi guncellendi')),
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
        roles: _roles,
        displayBranchName: _displayBranchName,
      ),
    );
    if (!mounted || saved != true) return;

    await _refreshCurrentUserList();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${user.firstName} ${user.lastName} icin rol ve şube guncellendi',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final me = authState is AuthAuthenticated ? authState.user : null;
    final departments = _departmentItems();
    final showAddDepartmentFab = _section == _AdminSection.branches;
    final showAddCustomerFab = _section == _AdminSection.customers;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
        leading: const SizedBox.shrink(),
        centerTitle: true,
        title: Column(
          children: [
            const Text('Admin', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(_subtitle(), style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          GoldGradientIconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: AppDrawerAdmin(
        expandedSection: _expandedDrawerSection,
        onAdminHeaderTap: () =>
            _toggleDrawerSection(AppDrawerMainSection.admin),
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
              hintText: _section == _AdminSection.branches
                  ? 'Şube ara...'
                  : _section == _AdminSection.personnel
                  ? 'Personel ara...'
                  : _section == _AdminSection.customers
                  ? 'Musteri ara...'
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
                            child: Text('Şube'),
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
                          _applyPersonnelFilters();
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
                          _applyPersonnelFilters();
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
                : _section == _AdminSection.branches
                ? _departmentsList(departments)
                : BlocBuilder<PaginatedUsersCubit, PaginatedUsersState>(
                    bloc: _activeUsersCubit,
                    builder: (context, state) {
                      if (state.isLoadingInitial && state.items.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.error != null && state.items.isEmpty) {
                        return Center(child: Text(state.error!));
                      }
                      return _usersList(
                        items: state.items,
                        controller: _activeUsersScrollController,
                        isLoadingMore: state.isLoadingMore,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _section.index,
        onDestinationSelected: (index) {
          _changeSection(_AdminSection.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: '',
          ),
        ],
      ),
      floatingActionButton: showAddDepartmentFab
          ? GeneralButton(
              text: 'Şube ekle',
              onPressed: _showAddDepartmentBottomSheet,
              variant: GeneralButtonVariant.gold,
            )
          : showAddCustomerFab
          ? GeneralButton(
              text: 'Müşteri ekle',
              onPressed: _showAddCustomerBottomSheet,
              variant: GeneralButtonVariant.gold,
            )
          : null,
    );
  }

  Widget _usersList({
    required List<User> items,
    required ScrollController controller,
    required bool isLoadingMore,
  }) {
    if (items.isEmpty) {
      return const Center(child: Text('Kayit bulunamadi'));
    }
    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + 80,
      ),
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (isLoadingMore && index == items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final user = items[index];
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
                      const Text(''),
                    ],
                  )
                else if (_section == _AdminSection.customers)
                  const SizedBox.shrink()
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
      return const Center(child: Text('Şube bulunamadi'));
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

  String _selectedBranchLabel() {
    if (_selectedBranchId == null) return 'Şube';
    for (final branch in _branches) {
      if (branch.id == _selectedBranchId) {
        return _displayBranchName(branch);
      }
    }
    return 'Şube';
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
  late int _level;
  late bool _isActive;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final b = widget.branch;
    _nameCtrl = TextEditingController(text: b.name);
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
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Şube adi zorunlu');
      return;
    }

    final code = widget.branch.code.trim();

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
      setState(() => _errorText = 'Şube guncellenirken hata olustu');
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
                        'Şube Duzenle',
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
                  'Şube Adi',
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
                  hintText: 'Şubenin adi',
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
    required this.roles,
    required this.displayBranchName,
  });

  final AdminRepository repo;
  final User user;
  final List<Role> roles;
  final String Function(Branch branch) displayBranchName;

  @override
  State<_AssignRoleBranchSheet> createState() => _AssignRoleBranchSheetState();
}

class _AssignRoleBranchSheetState extends State<_AssignRoleBranchSheet> {
  static const Set<String> _rolesWithoutBranch = {'admin', 'prod_op', 'wh_op'};

  String? _selectedBranchId;
  String? _selectedRoleId;
  bool _submitting = false;
  bool _branchesLoading = false;
  String? _errorText;
  List<Branch> _branches = const [];

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.user.branch?.id;
    _selectedRoleId = widget.user.role?.id;
    if (_currentRoleNeedsBranch()) {
      _loadBranches();
    }
  }

  Iterable<Role> get _visibleRoles =>
      widget.roles.where((r) => r.code != 'customer');

  Role? get _currentRole {
    final id = _selectedRoleId;
    if (id == null) return null;
    for (final r in widget.roles) {
      if (r.id == id) return r;
    }
    return null;
  }

  bool _currentRoleNeedsBranch() {
    final role = _currentRole;
    if (role == null) return false;
    return !_rolesWithoutBranch.contains(role.code);
  }

  Future<void> _loadBranches() async {
    setState(() {
      _branchesLoading = true;
      _errorText = null;
    });
    try {
      final list = await widget.repo.getBranches(type: 'branch');
      if (!mounted) return;
      setState(() {
        _branches = list;
        if (_selectedBranchId != null &&
            !list.any((b) => b.id == _selectedBranchId)) {
          _selectedBranchId = null;
        }
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'Şubeler yuklenemedi');
    } finally {
      if (mounted) {
        setState(() => _branchesLoading = false);
      }
    }
  }

  void _onRoleChanged(String? roleId) {
    setState(() {
      _selectedRoleId = roleId;
      if (roleId == null) {
        _selectedBranchId = null;
      }
    });

    final role = _currentRole;
    if (role == null) return;
    if (_rolesWithoutBranch.contains(role.code)) {
      setState(() => _selectedBranchId = null);
    } else if (_branches.isEmpty && !_branchesLoading) {
      _loadBranches();
    }
  }

  Future<void> _submit() async {
    if (_selectedRoleId == null) {
      setState(() => _errorText = 'Lutfen rol secin');
      return;
    }

    final needsBranch = _currentRoleNeedsBranch();
    if (needsBranch && _selectedBranchId == null) {
      setState(() => _errorText = 'Lutfen şube secin');
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
        branchId: needsBranch ? _selectedBranchId : null,
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
                'Rol Ekle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _sheetDropdown(
                value: _selectedRoleId,
                hint: 'Rol secin',
                enabled: !_submitting,
                items: _visibleRoles
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: _onRoleChanged,
              ),
              if (_currentRoleNeedsBranch()) ...[
                const SizedBox(height: 16),
                const Text(
                  'Şube Ekle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _sheetDropdown(
                  value: _selectedBranchId,
                  hint: _branchesLoading
                      ? 'Şubeler yukleniyor...'
                      : 'Şube Secin',
                  enabled: !_submitting && !_branchesLoading,
                  items: _branches
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.id,
                          child: Text(widget.displayBranchName(e)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBranchId = v),
                ),
              ],
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
              const SizedBox(height: 80),
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
      setState(() => _errorText = 'Şube adi zorunlu');
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
      setState(() => _errorText = 'Şube eklenirken hata olustu');
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
                      'Yeni Şube Ekle',
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
                'Şube Adi',
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
                hintText: 'Şubenin adi',
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

class _AddCustomerSheet extends StatefulWidget {
  const _AddCustomerSheet({
    required this.repo,
    required this.customerRole,
    required this.initials,
  });

  final AdminRepository repo;
  final Role customerRole;
  final String Function(User user) initials;

  @override
  State<_AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<_AddCustomerSheet> {
  String? _submittingUserId;
  String? _errorText;
  final TextEditingController _userSearchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final PaginatedUsersCubit _usersCubit;

  static bool _isCustomerUser(User user) => user.role?.code == 'customer';

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      _usersCubit.loadMore();
    }
  }

  @override
  void initState() {
    super.initState();
    _usersCubit = PaginatedUsersCubit(
      repository: widget.repo,
      isPersonel: false,
      userFilter: (user) => !_isCustomerUser(user),
    );
    _scrollController.addListener(_onScroll);
    _usersCubit.loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _usersCubit.close();
    _userSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onUserTap(User user) async {
    if (_submittingUserId != null) return;
    setState(() {
      _submittingUserId = user.id;
      _errorText = null;
    });

    try {
      await widget.repo.assignUserRoleAndBranch(
        userId: user.id,
        roleId: widget.customerRole.id,
        branchId: null,
      );
      if (!mounted) return;
      Navigator.of(context).pop(user);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'Musteri eklenirken hata olustu');
    } finally {
      if (mounted) {
        setState(() => _submittingUserId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
                      'Musteri Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _submittingUserId != null
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 30),
                    splashRadius: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Kullanicilar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _userSearchCtrl,
                onSubmitted: (value) =>
                    _usersCubit.updateFilters(search: value),
                decoration: InputDecoration(
                  hintText: 'Kullanici adi veya e-posta ile ara',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: _userSearchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _userSearchCtrl.clear();
                            _usersCubit.updateFilters(search: null);
                            setState(() {});
                          },
                          icon: const Icon(Icons.close, color: Colors.black45),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<PaginatedUsersCubit, PaginatedUsersState>(
                  bloc: _usersCubit,
                  builder: (context, state) {
                    if (state.isLoadingInitial && state.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error != null && state.items.isEmpty) {
                      return Center(child: Text(state.error!));
                    }
                    if (state.items.isEmpty) {
                      return const Center(child: Text('Kullanici bulunamadi'));
                    }
                    return ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 80,
                      ),
                      itemCount:
                          state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (state.isLoadingMore &&
                            index == state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        final user = state.items[index];
                        final isSubmitting = _submittingUserId == user.id;
                        final isDisabled =
                            _submittingUserId != null && !isSubmitting;
                        return Opacity(
                          opacity: isDisabled ? 0.5 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffe7eaec),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.mainColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.initials(user),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user.firstName} ${user.lastName}'
                                            .trim(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Color(0xff2d2d2d),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSubmitting)
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  IconButton(
                                    onPressed: isDisabled
                                        ? null
                                        : () => _onUserTap(user),
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: Colors.black45,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
