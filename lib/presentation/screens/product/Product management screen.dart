import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/products/products_cubit.dart';
import '../../../logic/products/products_state.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredProducts = [];
  List<dynamic> _allProducts = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductsCubit>().getProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _allProducts
          .where((p) =>
          p['name'].toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F4FD),
                ),
                child: Image.asset("assets/icons/logo.png", width: 35, height: 35),
              ),
            ),
          ],
        ),
        body: BlocConsumer<ProductsCubit, ProductsState>(
          listener: (context, state) {
            if (state is ProductsSuccess) {
              setState(() {
                _allProducts = state.products;
                _filteredProducts = state.products;
              });
            } else if (state is ProductsAddSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت العملية بنجاح ✅'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProductsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMsg),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 10),

                // العنوان
                const Text(
                  'ادارت المنتجات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 16),

                // زر إضافة منتج
                GestureDetector(
                  onTap: () => _showAddProductDialog(context),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'اضافة منتج',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.add_circle_outline,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // حقل البحث
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF0EA5E9)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlign: TextAlign.right,
                      onChanged: _filterProducts,
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن عميل أو رقم رف',
                        hintTextDirection: TextDirection.rtl,
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // القائمة
                Expanded(
                  child: state is ProductsLoading && _filteredProducts.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredProducts.isEmpty
                      ? const Center(
                    child: Text('لا يوجد منتجات',
                        style: TextStyle(color: Colors.grey)),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) =>
                        _buildProductCard(
                            _filteredProducts[index]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // أزرار الحذف والتعديل
          Column(
            children: [
              GestureDetector(
                onTap: () => _showDeleteDialog(context, product),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: Colors.red.withOpacity(0.6)),
                  ),
                  child: const Text(
                    'حذف',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showEditProductDialog(context, product),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'التعديل',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // الأسعار
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildPriceBox('سعر البيع',
                    '\$${product['selling_price'] ?? 0}'),
                const SizedBox(width: 8),
                _buildPriceBox('سعر التكلفة',
                    '\$${product['cost_price'] ?? 0}'),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // اسم المنتج + أيقونة
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_drink,
                    color: Color(0xFF0EA5E9), size: 28),
              ),
              const SizedBox(height: 4),
              Text(
                product['name'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(String label, String value) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436))),
        ],
      ),
    );
  }

  // ===== Dialog إضافة منتج =====
  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    String selectedType = 'sale';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocConsumer<ProductsCubit, ProductsState>(
                  listener: (context, state) {
                    if (state is ProductsAddSuccess) {
                      Navigator.pop(ctx);
                    } else if (state is ProductsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMsg),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_box_outlined,
                            size: 32, color: Color(0xFF2196F3)),
                        const SizedBox(height: 8),
                        const Text('اضافة منتج',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        // نوع المنتج
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setStateDialog(
                                        () => selectedType = 'sale'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedType == 'sale'
                                        ? const Color(0xFF2196F3)
                                        : const Color(0xFFF5F6FA),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('بيع',
                                      style: TextStyle(
                                          color: selectedType == 'sale'
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setStateDialog(
                                        () => selectedType = 'charging'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedType == 'charging'
                                        ? const Color(0xFF2196F3)
                                        : const Color(0xFFF5F6FA),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('شحن',
                                      style: TextStyle(
                                          color:
                                          selectedType == 'charging'
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _dialogTextField(nameCtrl, 'اسم المنتج'),
                        const SizedBox(height: 10),
                        _dialogTextField(costCtrl, 'سعر التكلفة',
                            isNumber: true),
                        const SizedBox(height: 10),
                        _dialogTextField(sellCtrl, 'سعر البيع',
                            isNumber: true),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: state is ProductsLoading
                                    ? null
                                    : () {
                                  if (nameCtrl.text.isEmpty) {
                                    return;
                                  }
                                  context
                                      .read<ProductsCubit>()
                                      .addProduct(
                                    nameCtrl.text.trim(),
                                    selectedType,
                                    double.tryParse(
                                        costCtrl.text) ??
                                        0,
                                    double.tryParse(
                                        sellCtrl.text) ??
                                        0,
                                  );
                                },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: state is ProductsLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                    CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2),
                                  )
                                      : const Text('إضافة',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(ctx),
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('إلغاء'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===== Dialog تعديل منتج =====
  void _showEditProductDialog(BuildContext context, dynamic product) {
    final nameCtrl =
    TextEditingController(text: product['name'] ?? '');
    final costCtrl = TextEditingController(
        text: (product['cost_price'] ?? 0).toString());
    final sellCtrl = TextEditingController(
        text: (product['selling_price'] ?? 0).toString());
    String selectedType = product['type'] ?? 'sale';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocConsumer<ProductsCubit, ProductsState>(
                  listener: (context, state) {
                    if (state is ProductsSuccess) {
                      Navigator.pop(ctx);
                    } else if (state is ProductsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMsg),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 32, color: Color(0xFF2196F3)),
                        const SizedBox(height: 8),
                        Text(
                          'تعديل العملية : ${product['name']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // نوع المنتج
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setStateDialog(
                                        () => selectedType = 'sale'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedType == 'sale'
                                        ? const Color(0xFF2196F3)
                                        : const Color(0xFFF5F6FA),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('بيع',
                                      style: TextStyle(
                                          color: selectedType == 'sale'
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setStateDialog(
                                        () => selectedType = 'charging'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedType == 'charging'
                                        ? const Color(0xFF2196F3)
                                        : const Color(0xFFF5F6FA),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('شحن',
                                      style: TextStyle(
                                          color:
                                          selectedType == 'charging'
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ملاحظة السعر
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'القيمة يجب أن تكون بين سعر التكلفة و سعر البيع المدخل على الشاشة الرئيسية',
                            style: TextStyle(
                                fontSize: 11, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _dialogTextField(costCtrl, 'سعر التكلفة',
                            isNumber: true),
                        const SizedBox(height: 10),
                        _dialogTextField(sellCtrl, 'سعر البيع',
                            isNumber: true),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: state is ProductsLoading
                                    ? null
                                    : () {
                                  context
                                      .read<ProductsCubit>()
                                      .updateProduct(
                                    product['id'].toString(),
                                    nameCtrl.text.trim(),
                                    selectedType,
                                    double.tryParse(
                                        costCtrl.text) ??
                                        0,
                                    double.tryParse(
                                        sellCtrl.text) ??
                                        0,
                                  );
                                },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: state is ProductsLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                    CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2),
                                  )
                                      : const Text('حفظ التعديل',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(ctx),
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('إلغاء'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===== Dialog حذف منتج =====
  void _showDeleteDialog(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 25, horizontal: 20),
            child: BlocConsumer<ProductsCubit, ProductsState>(
              listener: (context, state) {
                if (state is ProductsSuccess) {
                  Navigator.pop(ctx);
                } else if (state is ProductsError) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMsg),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('حذف المنتج',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Tajawal'),
                        children: [
                          const TextSpan(text: 'هل أنت متأكد من '),
                          const TextSpan(
                              text: 'حذف ',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          const TextSpan(text: 'المنتج '),
                          TextSpan(
                            text: '"${product['name']}"',
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: '؟'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: state is ProductsLoading
                              ? null
                              : () {
                            context
                                .read<ProductsCubit>()
                                .deleteProduct(
                                product['id'].toString());
                          },
                          child: Container(
                            width: 100,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            alignment: Alignment.center,
                            child: state is ProductsLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2),
                            )
                                : const Text('حذف',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 100,
                            height: 45,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            alignment: Alignment.center,
                            child: const Text('إلغاء'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogTextField(
      TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      textAlign: TextAlign.right,
      keyboardType:
      isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}