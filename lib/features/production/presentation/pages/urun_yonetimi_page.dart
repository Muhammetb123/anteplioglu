import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/di.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/gold_gradient_icon_button.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../logic/product/product_cubit.dart';
import '../../logic/product/product_state.dart';
import '../widgets/category_filter_widget.dart';
import '../widgets/product_card_widget.dart';

@RoutePage()
class UrunYonetimiPage extends StatelessWidget {
  const UrunYonetimiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductCubit(getIt<IProductRepository>())..loadProducts(),
      child: const _UrunYonetimiView(),
    );
  }
}

class _UrunYonetimiView extends StatefulWidget {
  const _UrunYonetimiView();

  @override
  State<_UrunYonetimiView> createState() => _UrunYonetimiViewState();
}

class _UrunYonetimiViewState extends State<_UrunYonetimiView> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    context.read<ProductCubit>().loadProducts(
          search: value.isEmpty ? null : value,
          categoryId: _selectedCategoryId,
        );
  }

  void _selectCategory(String? id) {
    setState(() => _selectedCategoryId = id);
    context.read<ProductCubit>().loadProducts(
          search: _searchController.text.isEmpty
              ? null
              : _searchController.text,
          categoryId: id,
        );
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
        title: const Text('Ürün Yönetimi',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          GoldGradientIconButton(
            icon: Icons.notifications_outlined,
            iconColor: Colors.black,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocListener<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            context.read<ProductCubit>().loadProducts(
                  categoryId: _selectedCategoryId,
                );
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            final categories =
                state is ProductsLoaded ? state.categories : <CategoryModel>[];
            final products =
                state is ProductsLoaded ? state.items : <ProductModel>[];
            final loading = state is ProductLoading;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // "Ürün Ekle" button — right-aligned row above search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showUrunEkleSheet(context, categories),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldGradientColor2,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text('Ürün Ekle',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                // Search bar — full width
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: 'Ürün ara...',
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xff9e9e9e)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Category filter chips
                if (categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CategoryFilterWidget(
                      categories: categories,
                      selectedId: _selectedCategoryId,
                      onSelected: _selectCategory,
                    ),
                  ),
                const SizedBox(height: 8),
                // Product list
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : products.isEmpty
                          ? const Center(child: Text('Ürün bulunamadı'))
                          : RefreshIndicator(
                              onRefresh: () =>
                                  context.read<ProductCubit>().loadProducts(
                                        categoryId: _selectedCategoryId,
                                      ),
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 4, 16, 32),
                                itemCount: products.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (context, i) {
                                  final p = products[i];
                                  return ProductCardWidget(
                                    product: p,
                                    onTap: () => context.router.push(
                                        UrunDetayiRoute(productId: p.id)),
                                    onToggle: (val) => context
                                        .read<ProductCubit>()
                                        .updateProduct(p.id,
                                            isActive: val),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showUrunEkleSheet(
      BuildContext context, List<CategoryModel> categories) {
    showDialog(
      context: context,
      builder: (_) => _UrunEkleDialog(
        categories: categories,
        cubit: context.read<ProductCubit>(),
      ),
    );
  }
}

class _UrunEkleDialog extends StatefulWidget {
  const _UrunEkleDialog({required this.categories, required this.cubit});

  final List<CategoryModel> categories;
  final ProductCubit cubit;

  @override
  State<_UrunEkleDialog> createState() => _UrunEkleDialogState();
}

class _UrunEkleDialogState extends State<_UrunEkleDialog> {
  final _trController = TextEditingController();
  final _enController = TextEditingController();
  final _deController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  String? _selectedCategoryId;

  @override
  void dispose() {
    _trController.dispose();
    _enController.dispose();
    _deController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _save() {
    if (_trController.text.isEmpty ||
        _unitController.text.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen zorunlu alanları doldurun')));
      return;
    }
    widget.cubit.createProduct(
      name: {
        'tr': _trController.text,
        'en': _enController.text,
        'de': _deController.text,
      },
      unit: _unitController.text,
      criticalStock: 0,
      categoryId: _selectedCategoryId!,
      quantity: num.tryParse(_stockController.text) ?? 0,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (not scrollable)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Ürünler',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 2, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Ürün Detaylarını Girin',
                    style:
                        TextStyle(fontSize: 13, color: Color(0xff9e9e9e))),
              ),
            ),
            // Scrollable form body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document upload area
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xffC2A463),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xffFBEAC4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.create_new_folder_outlined,
                                color: Color(0xffC2A463),
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Belge Yüklemek İçin Dokunun',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PNG, PDF ve JPG formatları desteklenir (maks. 50 MB)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff9e9e9e)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Ürün Adı',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1f1f1f))),
                    const SizedBox(height: 10),
                    _buildInlineField(
                        'TR', _trController, 'Türkçe ürün adı'),
                    const SizedBox(height: 8),
                    _buildInlineField(
                        'EN', _enController, 'İngilizce ürün adı'),
                    const SizedBox(height: 8),
                    _buildInlineField(
                        'DE', _deController, 'Almanca ürün adı'),
                    const SizedBox(height: 16),
                    const Text('Kategori',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1f1f1f))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      hint: const Text('Kategori Seçin',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xff9e9e9e))),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xfff0f0f0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      items: widget.categories
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name.tr)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLabeledField(
                              'Birim', _unitController, 'Adet'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLabeledField(
                            'Stok',
                            _stockController,
                            '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Kaydet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Inline label + text field (TR/EN/DE pattern from Figma)
  Widget _buildInlineField(
    String lang,
    TextEditingController controller,
    String hint,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(lang,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xff1f1f1f))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 14, color: Color(0xff9e9e9e)),
              filled: true,
              fillColor: const Color(0xfff0f0f0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // Labeled field for Birim/Stok (label above, field below)
  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff1f1f1f))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 14, color: Color(0xff9e9e9e)),
            filled: true,
            fillColor: const Color(0xfff0f0f0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
