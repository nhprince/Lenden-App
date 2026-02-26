import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/api/api_client.dart';
import '../core/models/models.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});
  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/api/products');
      setState(() {
        _products = (res.data as List).map((e) => Product.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Product> get _filtered {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _products;
    return _products.where((p) =>
      p.name.toLowerCase().contains(q) ||
      (p.sku?.toLowerCase().contains(q) ?? false) ||
      (p.category?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isEn = lang == 'en';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: isEn ? 'Search products...' : 'পণ্য খুঁজুন...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          })
                      : null,
                ),
              ),
            ),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.package_, size: 48, color: AppTheme.textLight),
                      const SizedBox(height: 12),
                      Text(isEn ? 'No products found' : 'কোনো পণ্য পাওয়া যায়নি'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final p = _filtered[i];
                    return _ProductTile(
                      product: p,
                      isEn: isEn,
                      canViewProfits: ref.read(authProvider.notifier).can('view_profits'),
                      onEdit: () => _showProductForm(p),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(null),
        backgroundColor: AppTheme.primary600,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  void _showProductForm(Product? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductForm(product: product, onSaved: _load),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final bool isEn;
  final bool canViewProfits;
  final VoidCallback onEdit;

  const _ProductTile({
    required this.product,
    required this.isEn,
    required this.canViewProfits,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onEdit,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary50,
            borderRadius: BorderRadius.circular(12),
            image: product.image != null
                ? (product.image!.startsWith('data:')
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(product.image!.split(',').last)),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: CachedNetworkImageProvider(product.image!),
                        fit: BoxFit.cover,
                      ))
                : null,
          ),
          child: product.image == null
              ? const Icon(LucideIcons.package_, color: AppTheme.primary600, size: 24)
              : null,
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  LucideIcons.layers,
                  size: 14,
                  color: product.isLowStock ? AppTheme.danger500 : AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isEn ? 'Stock' : 'মজুদ'}: ${product.stockQuantity} ${product.unit ?? 'pcs'}',
                  style: TextStyle(
                    color: product.isLowStock ? AppTheme.danger500 : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: product.isLowStock ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
            if (product.sku != null && product.sku!.isNotEmpty)
              Text(
                'SKU: ${product.sku}',
                style: TextStyle(color: AppTheme.textLight, fontSize: 11),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '৳${product.sellingPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primary600),
            ),
            if (canViewProfits)
              Text(
                '${isEn ? 'Profit' : 'লাভ'}: ৳${(product.sellingPrice - product.costPrice).toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  final Product? product;
  final VoidCallback onSaved;

  const _ProductForm({this.product, required this.onSaved});

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _costController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _unitController;
  late TextEditingController _categoryController;
  late TextEditingController _engineController;
  late TextEditingController _chassisController;
  
  File? _imageFile;
  String? _base64Image;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _skuController = TextEditingController(text: p?.sku);
    _costController = TextEditingController(text: p?.costPrice.toString());
    _priceController = TextEditingController(text: p?.sellingPrice.toString());
    _stockController = TextEditingController(text: p?.stockQuantity.toString());
    _unitController = TextEditingController(text: p?.unit);
    _categoryController = TextEditingController(text: p?.category);
    _engineController = TextEditingController(text: p?.engineNumber);
    _chassisController = TextEditingController(text: p?.chassisNumber);
    _base64Image = p?.image;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'name': _nameController.text,
      'sku': _skuController.text,
      'cost_price': double.parse(_costController.text),
      'selling_price': double.parse(_priceController.text),
      'stock_quantity': int.parse(_stockController.text),
      'unit': _unitController.text,
      'category': _categoryController.text,
      'engine_no': _engineController.text,
      'chassis_no': _chassisController.text,
      'image_url': _base64Image,
    };

    try {
      if (widget.product == null) {
        await ApiClient().dio.post('/api/products', data: data);
      } else {
        await ApiClient().dio.put('/api/products/${widget.product!.id}', data: data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving product')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider) == 'en';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(widget.product == null ? LucideIcons.plusCircle : LucideIcons.edit3, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      widget.product == null 
                          ? (isEn ? 'Add Product' : 'নতুন পণ্য')
                          : (isEn ? 'Edit Product' : 'সম্পাদনা'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primary50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primary100),
                            image: _base64Image != null
                                ? DecorationImage(
                                    image: _imageFile != null 
                                        ? FileImage(_imageFile!) as ImageProvider
                                        : MemoryImage(base64Decode(_base64Image!.split(',').last)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _base64Image == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.camera, color: AppTheme.primary600, size: 32),
                                    SizedBox(height: 4),
                                    Text('Add Photo', style: TextStyle(fontSize: 12, color: AppTheme.primary600)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildField(isEn ? 'Product Name*' : 'পণ্যের নাম*', _nameController, LucideIcons.package_, required: true),
                    Row(
                      children: [
                        Expanded(child: _buildField(isEn ? 'Cost Price*' : 'ক্রয় মূল্য*', _costController, LucideIcons.tag, type: TextInputType.number, required: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(isEn ? 'Selling Price*' : 'বিক্রয় মূল্য*', _priceController, LucideIcons.dollarSign, type: TextInputType.number, required: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildField(isEn ? 'Stock*' : 'মজুদ*', _stockController, LucideIcons.layers, type: TextInputType.number, required: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(isEn ? 'Unit' : 'একক', _unitController, LucideIcons.box, hint: 'pcs, kg, etc.')),
                      ],
                    ),
                    _buildField('SKU / Barcode', _skuController, LucideIcons.barcode),
                    _buildField(isEn ? 'Category' : 'ক্যাটাগরি', _categoryController, LucideIcons.grid),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Industry Specific (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey)),
                    ),
                    _buildField(isEn ? 'Engine Number' : 'ইঞ্জিন নম্বর', _engineController, LucideIcons.settings),
                    _buildField(isEn ? 'Chassis Number' : 'চ্যাসিস নম্বর', _chassisController, LucideIcons.truck),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isEn ? 'Save Product' : 'সংরক্ষণ করুন'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool required = false, TextInputType type = TextInputType.text, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
