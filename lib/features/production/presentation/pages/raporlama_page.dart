import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/di.dart';
import '../../../../core/widgets/gold_gradient_icon_button.dart';
import '../../data/models/report_model.dart';
import '../../domain/repositories/i_report_repository.dart';
import '../../logic/report/report_cubit.dart';
import '../../logic/report/report_state.dart';

@RoutePage()
class RaporlamaPage extends StatelessWidget {
  const RaporlamaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportCubit(getIt<IReportRepository>()),
      child: const _RaporlamaView(),
    );
  }
}

class _RaporlamaView extends StatefulWidget {
  const _RaporlamaView();

  @override
  State<_RaporlamaView> createState() => _RaporlamaViewState();
}

class _RaporlamaViewState extends State<_RaporlamaView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<ReportCubit>().loadByProduct();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      context.read<ReportCubit>().loadByProduct();
    } else {
      context.read<ReportCubit>().loadByBranch();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: const Text(
          'Raporlama',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          GoldGradientIconButton(
            icon: Icons.add,
            iconColor: Colors.black,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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

class _UruneGoreTab extends StatelessWidget {
  const _UruneGoreTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportError) {
          return Center(child: Text(state.message));
        }
        if (state is! ReportByProductLoaded) {
          return const SizedBox.shrink();
        }

        final items = state.data.items;

        return Column(
          children: [
            _DateFilterBar(
              onDateChanged: (start, end) =>
                  context.read<ReportCubit>().loadByProduct(
                        startDate: start,
                        endDate: end,
                      ),
            ),
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () =>
                        context.read<ReportCubit>().loadByProduct(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          _ProductReportAccordion(item: items[i]),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _TotalCard(total: state.data.grandTotal),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SubeyeGoreTab extends StatelessWidget {
  const _SubeyeGoreTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportError) {
          return Center(child: Text(state.message));
        }
        if (state is! ReportByBranchLoaded) {
          return const SizedBox.shrink();
        }

        final items = state.data.items;

        return Column(
          children: [
            _DateFilterBar(
              onDateChanged: (start, end) =>
                  context.read<ReportCubit>().loadByBranch(
                        startDate: start,
                        endDate: end,
                      ),
            ),
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () =>
                        context.read<ReportCubit>().loadByBranch(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          _BranchReportAccordion(item: items[i]),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _TotalCard(total: state.data.grandTotal),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DateFilterBar extends StatefulWidget {
  const _DateFilterBar({required this.onDateChanged});

  final void Function(String? startDate, String? endDate) onDateChanged;

  @override
  State<_DateFilterBar> createState() => _DateFilterBarState();
}

class _DateFilterBarState extends State<_DateFilterBar> {
  DateTimeRange? _range;
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  String get _displayText {
    if (_range == null) return '';
    final s = _range!.start;
    final e = _range!.end;
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    return '${fmt(s)} – ${fmt(e)}';
  }

  String _toApiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _range,
      locale: const Locale('tr'),
    );
    if (picked == null) return;
    setState(() {
      _range = picked;
      _dateController.text = _displayText;
    });
    widget.onDateChanged(_toApiDate(picked.start), _toApiDate(picked.end));
  }

  void _clear() {
    setState(() {
      _range = null;
      _dateController.clear();
    });
    widget.onDateChanged(null, null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              readOnly: true,
              onTap: _pickRange,
              controller: _dateController,
              decoration: InputDecoration(
                hintText: 'Tarih',
                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                suffixIcon: _range != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _clear,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _pickRange,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductReportAccordion extends StatefulWidget {
  const _ProductReportAccordion({required this.item});

  final ReportByProductItemModel item;

  @override
  State<_ProductReportAccordion> createState() =>
      _ProductReportAccordionState();
}

class _ProductReportAccordionState extends State<_ProductReportAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.item.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.item.totalLineTotal.toStringAsFixed(0)}€',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            ...widget.item.byBranch.map(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.branchName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${b.quantity} Tepsi',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff5e5e5e),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      b.lineTotal > 0
                          ? '${b.lineTotal.toStringAsFixed(0)}€'
                          : '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _BranchReportAccordion extends StatefulWidget {
  const _BranchReportAccordion({required this.item});

  final ReportByBranchItemModel item;

  @override
  State<_BranchReportAccordion> createState() => _BranchReportAccordionState();
}

class _BranchReportAccordionState extends State<_BranchReportAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.item.branchName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.item.totalLineTotal.toStringAsFixed(0)}€',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            ...widget.item.byProduct.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                          ? Image.network(p.imageUrl!,
                              width: 40, height: 40, fit: BoxFit.cover)
                          : Container(
                              width: 40,
                              height: 40,
                              color: AppColors.goldBorderColor,
                              child: const Icon(Icons.bakery_dining_outlined,
                                  color: Colors.white, size: 20),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${p.quantity} Tepsi',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff5e5e5e),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (p.lineTotal > 0)
                      Text(
                        '${p.lineTotal.toStringAsFixed(0)}€',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final num total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        //  AppColors.mainColor,
        border: Border.all(color: AppColors.mainColor, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Toplam',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${total.toStringAsFixed(0)}€',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
