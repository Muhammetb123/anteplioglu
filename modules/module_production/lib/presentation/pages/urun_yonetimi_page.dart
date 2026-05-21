import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:module_produksiyon/module_produksiyon.dart';
import 'package:shared_ui/widgets/gold_gradient_icon_button.dart';
import '../widgets/category_filter_widget.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/urun_ekle_dialog.dart';

@RoutePage()
class UrunYonetimiPage extends StatelessWidget {
  const UrunYonetimiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductCubit>()..loadProducts(),
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
            isCircle: true,
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
                state is ProductsLoaded ? state.categories : <CategoryEntity>[];
            final products =
                state is ProductsLoaded ? state.items : <ProductEntity>[];
            final loading = state is ProductLoading;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // "Ürün Ekle" button — right-aligned row above search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: AppColors.goldGradient,
                        border: AppColors.goldBorder,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            _showUrunEkleSheet(context, categories),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xff1f1f1f),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                              
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          elevation: 0,
                        ),
                        child: const Text('Ürün Ekle',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
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
      BuildContext context, List<CategoryEntity> categories) {
    showDialog(
      context: context,
      builder: (_) => UrunEkleDialog(
        categories: categories,
        cubit: context.read<ProductCubit>(),
      ),
    );
  }
}
