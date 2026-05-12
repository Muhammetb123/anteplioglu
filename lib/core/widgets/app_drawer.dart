import 'package:antepli/core/constants/svg_paths.dart';
import 'package:antepli/core/utils.dart';
import 'package:antepli/features/auth/logic/auth_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/logic/auth_cubit.dart';

enum AppDrawerMainSection { admin, warehouse, production }

/// Depo alt çizelgesindeki "Kategori" metni — seçim (`selectedWarehouseSubItem`) ile eşleşmeli.
const kAppDrawerWarehouseKategoriTitle = 'Kategori';

/// Produksiyon alt çizelgesindeki "Anasayfa" metni — seçim ile eşleşmeli.
const kAppDrawerProductionAnasayfaTitle = 'Anasayfa';

const _kWarehouseTitles = [
  kAppDrawerWarehouseKategoriTitle,
  'Urunler',
  'Siparis Yonetimi',
  'Stok Hareketi',
  'Raporlar',
];

const _kProductionTitles = [
  kAppDrawerProductionAnasayfaTitle,
  'Urun Yonetimi',
  'Siparis Yonetimi',
  'Ara Dolap',
  'Musteri Yonetimi',
  'Raporlar',
];

List<Widget> _tapDrawerRows(
  BuildContext context,
  List<String> titles,
  ValueChanged<String>? onItemTap,
  String? selectedTitle,
) {
  return [
    for (final title in titles)
      AppDrawerStaticItem(
        title: title,
        selected: selectedTitle != null && selectedTitle == title,
        onTap: () {
          Navigator.of(context).maybePop();
          onItemTap?.call(title);
        },
      ),
  ];
}

/// Admin ana sayfa — logo, scroll alanı, opsiyonel kullanıcı satırı.
class AppDrawerAdmin extends StatelessWidget {
  const AppDrawerAdmin({
    super.key,
    required this.expandedSection,
    required this.onAdminHeaderTap,
    required this.onWarehouseHeaderTap,
    required this.onProductionHeaderTap,
    this.footer,
    this.onWarehouseSubItemTap,
    this.onProductionSubItemTap,
    this.selectedWarehouseSubItem,
    this.selectedProductionSubItem,
  });

  final AppDrawerMainSection expandedSection;
  final VoidCallback onAdminHeaderTap;
  final VoidCallback onWarehouseHeaderTap;
  final VoidCallback onProductionHeaderTap;
  final Widget? footer;
  final ValueChanged<String>? onWarehouseSubItemTap;
  final ValueChanged<String>? onProductionSubItemTap;

  /// Depo altında vurgulanacak satır başlığı (`_kWarehouseTitles` ile aynı metin).
  final String? selectedWarehouseSubItem;

  /// Produksiyon altında vurgulanacak satır başlığı (`_kProductionTitles` ile aynı metin).
  final String? selectedProductionSubItem;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xff0d5a4b),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xffd9ddde),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: const SizedBox(width: 28, height: 28),
                  ),
                  const SizedBox(width: 10),
                  buildSvg(path: SvgPaths.antepliogluIcon, height: 24),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _DrawerGoldHeader(
                        label: 'Admin',
                        icon: Icons.admin_panel_settings,
                        expanded: expandedSection == AppDrawerMainSection.admin,
                        onTap: onAdminHeaderTap,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _DrawerGoldHeader(
                        label: 'Depo',
                        icon: Icons.local_offer,
                        expanded:
                            expandedSection == AppDrawerMainSection.warehouse,
                        onTap: onWarehouseHeaderTap,
                      ),
                    ),
                    _DrawerAnimatedSection.admin(
                      expanded:
                          expandedSection == AppDrawerMainSection.warehouse,
                      children: _tapDrawerRows(
                        context,
                        _kWarehouseTitles,
                        onWarehouseSubItemTap,
                        selectedWarehouseSubItem,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _DrawerGoldHeader(
                        label: 'Produksiyon',
                        icon: Icons.groups,
                        expanded:
                            expandedSection == AppDrawerMainSection.production,
                        onTap: onProductionHeaderTap,
                      ),
                    ),
                    _DrawerAnimatedSection.admin(
                      expanded:
                          expandedSection == AppDrawerMainSection.production,
                      children: _tapDrawerRows(
                        context,
                        _kProductionTitles,
                        onProductionSubItemTap,
                        selectedProductionSubItem,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}

/// Depo / Produksiyon sayfaları — alt kısımda çıkış butonu.
class AppDrawerBranch extends StatelessWidget {
  const AppDrawerBranch({
    super.key,
    required this.expandedSection,
    required this.onToggleSection,
    required this.onAdminTap,
    required this.onWarehouseTap,
    required this.onProductionTap,
    this.onWarehouseSubItemTap,
    this.onProductionSubItemTap,
    this.selectedWarehouseSubItem,
    this.selectedProductionSubItem,
  });

  final AppDrawerMainSection expandedSection;
  final ValueChanged<AppDrawerMainSection> onToggleSection;
  final VoidCallback onAdminTap;
  final VoidCallback onWarehouseTap;
  final VoidCallback onProductionTap;
  final ValueChanged<String>? onWarehouseSubItemTap;
  final ValueChanged<String>? onProductionSubItemTap;
  final String? selectedWarehouseSubItem;
  final String? selectedProductionSubItem;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final me = authState is AuthAuthenticated ? authState.user : null;
    return Drawer(
      backgroundColor: const Color(0xff0d5a4b),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: _DrawerGoldHeader(
                        label: 'Admin',
                        icon: Icons.admin_panel_settings,
                        expanded: expandedSection == AppDrawerMainSection.admin,
                        onTap: () {
                          onToggleSection(AppDrawerMainSection.admin);
                          onAdminTap();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: _DrawerGoldHeader(
                        label: 'Depo',
                        icon: Icons.local_offer,
                        expanded:
                            expandedSection == AppDrawerMainSection.warehouse,
                        onTap: () {
                          onToggleSection(AppDrawerMainSection.warehouse);
                          onWarehouseTap();
                        },
                      ),
                    ),
                    _DrawerAnimatedSection.branch(
                      expanded:
                          expandedSection == AppDrawerMainSection.warehouse,
                      children: _tapDrawerRows(
                        context,
                        _kWarehouseTitles,
                        onWarehouseSubItemTap,
                        selectedWarehouseSubItem,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: _DrawerGoldHeader(
                        label: 'Produksiyon',
                        icon: Icons.groups,
                        expanded:
                            expandedSection == AppDrawerMainSection.production,
                        onTap: () {
                          onToggleSection(AppDrawerMainSection.production);
                          onProductionTap();
                        },
                      ),
                    ),
                    _DrawerAnimatedSection.branch(
                      expanded:
                          expandedSection == AppDrawerMainSection.production,
                      children: _tapDrawerRows(
                        context,
                        _kProductionTitles,
                        onProductionSubItemTap,
                        selectedProductionSubItem,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            me == null
                ? SizedBox.shrink()
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
                                '${me.role?.name ?? ''} / ${me.branch?.name ?? ''}',
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
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 16),
            //   child: TextButton.icon(
            //     onPressed: () {
            //       context.read<AuthCubit>().signOut();
            //       context.router.maybePop();
            //     },
            //     icon: const Icon(Icons.logout, color: Colors.white),
            //     label: const Text(
            //       'Cikis Yap',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class AppDrawerStaticItem extends StatelessWidget {
  const AppDrawerStaticItem({
    super.key,
    required this.title,
    this.onTap,
    this.selected = false,
  });

  final String title;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            selected ? Icons.chevron_right : Icons.chevron_right_outlined,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: row,
      ),
    );
  }
}

class _DrawerGoldHeader extends StatelessWidget {
  const _DrawerGoldHeader({
    required this.label,
    required this.icon,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xffd4bc72),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: const Color(0xffc7ab5f)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerAnimatedSection extends StatelessWidget {
  const _DrawerAnimatedSection.admin({
    required this.expanded,
    required this.children,
  }) : duration = const Duration(milliseconds: 240),
       topGap = 8,
       bottomGap = 12,
       firstCurve = Curves.easeOut,
       secondCurve = Curves.easeIn;

  const _DrawerAnimatedSection.branch({
    required this.expanded,
    required this.children,
  }) : duration = const Duration(milliseconds: 220),
       topGap = 4,
       bottomGap = 8,
       firstCurve = null,
       secondCurve = null;

  final bool expanded;
  final List<Widget> children;
  final Duration duration;
  final double topGap;
  final double bottomGap;
  final Curve? firstCurve;
  final Curve? secondCurve;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Column(
        children: [
          SizedBox(height: topGap),
          ...children,
          SizedBox(height: bottomGap),
        ],
      ),
      crossFadeState: expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: duration,
      sizeCurve: Curves.easeInOutCubic,
      firstCurve: firstCurve ?? Curves.linear,
      secondCurve: secondCurve ?? Curves.linear,
      alignment: Alignment.topCenter,
    );
  }
}
