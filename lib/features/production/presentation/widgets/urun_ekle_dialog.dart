import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../../logic/product/product_cubit.dart';

class UrunEkleDialog extends StatefulWidget {
  const UrunEkleDialog({
    super.key,
    required this.categories,
    required this.cubit,
  });

  final List<CategoryEntity> categories;
  final ProductCubit cubit;

  @override
  State<UrunEkleDialog> createState() => _UrunEkleDialogState();
}

class _UrunEkleDialogState extends State<UrunEkleDialog> {
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
        const SnackBar(content: Text('Lütfen zorunlu alanları doldurun')),
      );
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (not scrollable)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ürünler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
              padding: EdgeInsets.only(left: 20, top: 2, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ürün Detaylarını Girin',
                  style: TextStyle(fontSize: 13, color: Color(0xff9e9e9e)),
                ),
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
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.goldBorderColor,
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
                                color: AppColors.goldGradientColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.create_new_folder_outlined,
                                color: AppColors.goldBorderColor,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Belge Yüklemek İçin Dokunun',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'PNG, PDF и JPG formatları desteklenir (maks. 50 MB)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff9e9e9e),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ürün Adı',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1f1f1f),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildInlineField('TR', _trController, 'Türkçe ürün adı'),
                    const SizedBox(height: 6),
                    _buildInlineField('EN', _enController, 'İngilizce ürün adı'),
                    const SizedBox(height: 6),
                    _buildInlineField('DE', _deController, 'Almanca ürün adı'),
                    const SizedBox(height: 12),
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1f1f1f),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      hint: const Text(
                        'Kategori Seçin',
                        style: TextStyle(fontSize: 14, color: Color(0xff9e9e9e)),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xfff0f0f0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      items: widget.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name.tr),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child:
                              _buildLabeledField('Birim', _unitController, 'Adet'),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Kaydet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  Widget _buildInlineField(
    String lang,
    TextEditingController controller,
    String hint,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            lang,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xff1f1f1f),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xff9e9e9e)),
              filled: true,
              fillColor: const Color(0xfff0f0f0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff1f1f1f),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xff9e9e9e)),
            filled: true,
            fillColor: const Color(0xfff0f0f0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}
