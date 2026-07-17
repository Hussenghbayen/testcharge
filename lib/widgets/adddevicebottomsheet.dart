import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/transactions/transactions_cubit.dart';
import '../logic/transactions/transactions_state.dart';

class AddDeviceBottomSheet extends StatefulWidget {
  const AddDeviceBottomSheet({super.key});

  @override
  State<AddDeviceBottomSheet> createState() => _AddDeviceBottomSheetState();
}

class _AddDeviceBottomSheetState extends State<AddDeviceBottomSheet> {
  final TextEditingController _shelfController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  // قائمة المنتجات (قائمة الأسعار) — تُجلب من الـ API
  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic>? _selectedProduct;
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data is List) ? data : (data['products'] as List? ?? []);
        setState(() {
          // خدمات الشحن فقط — منتجات البيع (sale) لا تظهر هنا
          _products = list
              .cast<Map<String, dynamic>>()
              .where((p) => p['type']?.toString() == 'charging')
              .toList();
          _loadingProducts = false;
        });
      } else {
        setState(() => _loadingProducts = false);
      }
    } catch (_) {
      setState(() => _loadingProducts = false);
    }
  }

  // السعر المستحق للمنتج المختار (الكمية = 1)
  double get _price {
    if (_selectedProduct == null) return 0;
    return double.tryParse(
        _selectedProduct!['selling_price']?.toString() ?? '0') ??
        0;
  }

  @override
  void dispose() {
    _shelfController.dispose();
    _customerController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تسجيل جهاز جديد',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // رقم الرف واسم العميل
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput('رقم الرف', '3', _shelfController,
                              TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildInput(
                              'اسم العميل', 'محمد', _customerController)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // نوع الجهاز — قائمة من المنتجات (قائمة الأسعار)
                  _buildProductDropdown(),
                  const SizedBox(height: 15),

                  // عرض السعر تلقائياً
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('السعر',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                        Text(
                          _selectedProduct == null
                              ? '—'
                              : '${_price.toStringAsFixed(2)} ₪',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // المدفوع الآن + أزرار سريعة
                  _buildInput('المدفوع الآن', '0.00', _amountController,
                      TextInputType.number),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _quickButton(
                          'لم يدفع (على الحساب)',
                          Colors.orange,
                              () => setState(() => _amountController.text = '0'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _quickButton(
                          _selectedProduct == null
                              ? 'دفع كامل'
                              : 'دفع كامل (${_price.toStringAsFixed(0)})',
                          Colors.green,
                          _selectedProduct == null
                              ? null
                              : () => setState(() => _amountController.text =
                              _price.toStringAsFixed(2)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // زر الحفظ مربوط بالـ Cubit
                  BlocConsumer<TransactionsCubit, TransactionsState>(
                    listener: (context, state) {
                      if (state is TransactionsSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تسجيل الجهاز بنجاح ✅'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is TransactionsError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMsg),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: state is TransactionsLoading ? null : _save,
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF1E3A8A)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: state is TransactionsLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            'حفظ الجهاز',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_shelfController.text.isEmpty ||
        _customerController.text.isEmpty ||
        _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول واختيار نوع الجهاز')),
      );
      return;
    }

    final paidNow = double.tryParse(_amountController.text) ?? 0;
    if (paidNow < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المبلغ المدفوع غير صحيح')),
      );
      return;
    }

    context.read<TransactionsCubit>().addTransaction(
      customerName: _customerController.text.trim(),
      productName: _selectedProduct!['name'].toString(),
      shelfNumber: _shelfController.text.trim(),
      amountPaid: paidNow,
      paymentStatus: 'debt', // الـ API يتجاهلها ويشتق الحالة تلقائياً من المبلغ
      type: 'charging',
    );
  }

  Widget _buildInput(
      String label, String hint, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  // قائمة المنتجات بدل حقل النص الحر — السعر من قائمة الأسعار مباشرة
  Widget _buildProductDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('نوع الجهاز / الخدمة',
            style: TextStyle(
                fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _loadingProducts
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('جاري تحميل قائمة الأسعار...',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          )
              : DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedProduct,
              isExpanded: true,
              hint: const Text('اختر من قائمة الأسعار',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              items: _products
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(
                    '${p['name']} — ${p['selling_price']} ₪'),
              ))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedProduct = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickButton(String label, Color color, VoidCallback? onTap) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade200 : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: disabled ? Colors.grey.shade300 : color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: disabled ? Colors.grey : color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}