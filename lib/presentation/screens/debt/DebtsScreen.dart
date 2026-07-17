import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../logic/customers/customers_cubit.dart';
import '../../../widgets/common_widgets.dart';
import 'customer_details_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  List<dynamic> _debtors = [];
  List<dynamic> _filtered = [];
  double _totalDebts = 0;
  int _count = 0;
  bool _loading = true;
  String _error = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDebtors();
  }

  Future<void> _fetchDebtors() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final token =
      await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard/debtors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _debtors = data['debtors'] as List? ?? [];
          _totalDebts =
              double.tryParse(data['total_debts'].toString()) ?? 0;
          _count = int.tryParse(data['count'].toString()) ?? 0;
          _applyFilter();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'فشل تحميل الديون';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'خطأ في الاتصال بالسيرفر';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    _filtered = _searchQuery.isEmpty
        ? List.from(_debtors)
        : _debtors
        .where((c) =>
        c['name'].toString().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Text(
              'ديون العملاء',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3B3B)),
            ),
            const SizedBox(height: 15),
            CustomSearchBar(
              hintText: 'ابحث عن مدين...',
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _applyFilter();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                  ? Center(child: Text(_error))
                  : _filtered.isEmpty
                  ? const Center(
                  child: Text('🎉 لا يوجد ديون — الكل مسدد!',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold)))
                  : RefreshIndicator(
                onRefresh: _fetchDebtors,
                child: ListView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) =>
                      _buildDebtCard(
                          context, _filtered[index]),
                ),
              ),
            ),
            _buildBottomSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back, color: Colors.black54),
          Image.asset("assets/icons/logo.png", width: 35, height: 35),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, dynamic customer) {
    final double balance =
        double.tryParse(customer['balance'].toString()) ?? 0;
    final double debt = balance.abs();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerDetailsScreen(
            customerId: customer['id'].toString(),
            customerName: customer['name']?.toString() ?? '',
          ),
        ),
      ).then((_) => _fetchDebtors()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showPayDialog(
                  context, customer['id'].toString(), debt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF166534)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('سداد',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${debt.toStringAsFixed(2)} ₪',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(customer['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Text(
                  'مبلغ مستحق',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.red.shade200,
              child: Text(
                customer['name'].toString()[0],
                style:
                const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(
      BuildContext context, String customerId, double debt) {
    final TextEditingController amountController =
    TextEditingController();
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          title: const Text('تسجيل دفعة', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الدين الحالي: ${debt.toStringAsFixed(2)} ₪',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(hintText: 'المبلغ'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(hintText: 'ملاحظة'),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                  amountController.text = debt.toStringAsFixed(2),
                  child: Text('سداد كامل (${debt.toStringAsFixed(0)})',
                      style: const TextStyle(color: Colors.green)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white),
              onPressed: () {
                final amount =
                    double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) return;
                context.read<CustomersCubit>().payDebt(
                    customerId, amount, noteController.text);
                Navigator.pop(context);
                // تحديث القائمة بعد لحظة (حتى يكتمل السداد على السيرفر)
                Future.delayed(const Duration(milliseconds: 800),
                    _fetchDebtors);
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text('المدينون: $_count',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
                'إجمالي الديون: ${_totalDebts.toStringAsFixed(2)} ₪',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );
  }
}