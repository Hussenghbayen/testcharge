import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// نافذة البيع السريع — للمنتجات المباشرة (مشروبات، إكسسوارات...)
/// - تعرض منتجات النوع sale فقط
/// - بلا رقم رف (لا تشغل رفاً)
/// - كمية + إجمالي تلقائي + "المدفوع الآن" بالمنطق المحاسبي الموحّد
class QuickSaleBottomSheet extends StatefulWidget {
  const QuickSaleBottomSheet({super.key});

  @override
  State<QuickSaleBottomSheet> createState() => _QuickSaleBottomSheetState();
}

class _QuickSaleBottomSheetState extends State<QuickSaleBottomSheet> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic>? _selectedProduct;
  bool _loadingProducts = true;
  bool _saving = false;
  int _quantity = 1;

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
          // منتجات البيع فقط — خدمات الشحن لا تظهر هنا
          _products = list
              .cast<Map<String, dynamic>>()
              .where((p) => p['type']?.toString() == 'sale')
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

  double get _unitPrice {
    if (_selectedProduct == null) return 0;
    return double.tryParse(
        _selectedProduct!['selling_price']?.toString() ?? '0') ??
        0;
  }

  double get _total => _unitPrice * _quantity;

  Future<void> _save() async {
    if (_customerController.text.trim().isEmpty || _selectedProduct == null) {
      _showSnack('يرجى إدخال اسم العميل واختيار المنتج', Colors.red);
      return;
    }
    final paidNow = double.tryParse(_amountController.text) ?? 0;
    if (paidNow < 0) {
      _showSnack('المبلغ المدفوع غير صحيح', Colors.red);
      return;
    }

    setState(() => _saving = true);
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "customer_name": _customerController.text.trim(),
          "product_name": _selectedProduct!['name'].toString(),
          "quantity": _quantity,
          "amount_paid": paidNow,
          "type": "sale",
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
        _showSnack('تم تسجيل البيع بنجاح ✅', Colors.green);
      } else {
        final data = jsonDecode(response.body);
        setState(() => _saving = false);
        _showSnack(data['message']?.toString() ?? 'فشل تسجيل البيع',
            Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack('خطأ في الاتصال بالسيرفر', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
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
                    'بيع سريع',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildInput('اسم العميل', 'محمد', _customerController),
                  const SizedBox(height: 15),

                  // المنتج — منتجات البيع فقط
                  _buildProductDropdown(),
                  const SizedBox(height: 15),

                  // الكمية + الإجمالي
                  Row(
                    children: [
                      Expanded(child: _buildQuantityStepper()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTotalBox()),
                    ],
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
                          'على الحساب',
                          Colors.orange,
                              () => setState(() => _amountController.text = '0'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _quickButton(
                          _selectedProduct == null
                              ? 'دفع كامل'
                              : 'دفع كامل (${_total.toStringAsFixed(0)})',
                          Colors.green,
                          _selectedProduct == null
                              ? null
                              : () => setState(() => _amountController.text =
                              _total.toStringAsFixed(2)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // زر التسجيل
                  GestureDetector(
                    onTap: _saving ? null : _save,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF166534)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: _saving
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : const Text(
                        'تسجيل البيع',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  Widget _buildProductDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('المنتج',
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
            child: Text('جاري تحميل المنتجات...',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          )
              : DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedProduct,
              isExpanded: true,
              hint: const Text('اختر المنتج',
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

  Widget _buildQuantityStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الكمية',
            style: TextStyle(
                fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Text('$_quantity',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الإجمالي',
            style: TextStyle(
                fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _selectedProduct == null
                ? '—'
                : '${_total.toStringAsFixed(2)} ₪',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF166534),
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