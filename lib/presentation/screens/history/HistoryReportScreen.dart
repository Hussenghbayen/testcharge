import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/common_widgets.dart';

class Historyreportscreen extends StatefulWidget {
  const Historyreportscreen({super.key});

  @override
  State<Historyreportscreen> createState() => _HistoryreportscreenState();
}

class _HistoryreportscreenState extends State<Historyreportscreen> {
  static const String _baseUrl = 'https://charging-api-tkne.onrender.com/api';

  List<Map<String, dynamic>> _timeline = [];
  bool _loading = true;
  String _error = '';
  String _typeFilter = 'الكل'; // الكل / شحن / بيع / إيداعات
  String _periodFilter = 'يومي'; // يومي / اسبوعي / شهري / الكل
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final txRes = await http.get(
          Uri.parse('$_baseUrl/transactions'), headers: headers);
      final payRes = await http.get(
          Uri.parse('$_baseUrl/customers/payments/all'), headers: headers);

      if (txRes.statusCode != 200 || payRes.statusCode != 200) {
        setState(() {
          _error = 'فشل تحميل السجل';
          _loading = false;
        });
        return;
      }

      final txData = jsonDecode(txRes.body);
      final List txList =
      (txData is List) ? txData : (txData['transactions'] as List? ?? []);

      final payData = jsonDecode(payRes.body);
      final List payList = payData['payments'] as List? ?? [];

      final List<Map<String, dynamic>> timeline = [];

      for (final t in txList) {
        timeline.add({
          'kind': 'tx',
          'when': DateTime.tryParse(
              (t['received_at'] ?? t['date'] ?? '').toString()) ??
              DateTime(2000),
          'data': Map<String, dynamic>.from(t),
        });
      }
      for (final p in payList) {
        timeline.add({
          'kind': 'pay',
          'when': DateTime.tryParse((p['paid_at'] ?? '').toString()) ??
              DateTime(2000),
          'data': Map<String, dynamic>.from(p),
        });
      }

      timeline.sort((a, b) =>
          (b['when'] as DateTime).compareTo(a['when'] as DateTime));

      setState(() {
        _timeline = timeline;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ في الاتصال بالسيرفر';
        _loading = false;
      });
    }
  }

  bool _inPeriod(DateTime when) {
    final now = DateTime.now();
    switch (_periodFilter) {
      case 'يومي':
        return when.year == now.year &&
            when.month == now.month &&
            when.day == now.day;
      case 'اسبوعي':
        return now.difference(when).inDays < 7;
      case 'شهري':
        return when.year == now.year && when.month == now.month;
      default: // الكل
        return true;
    }
  }

  List<Map<String, dynamic>> get _visible {
    return _timeline.where((e) {
      final data = e['data'] as Map<String, dynamic>;
      // فلتر الفترة
      if (!_inPeriod((e['when'] as DateTime).toLocal())) return false;
      // فلتر النوع
      if (_typeFilter == 'إيداعات' && e['kind'] != 'pay') return false;
      if (_typeFilter == 'شحن' &&
          !(e['kind'] == 'tx' && data['type'] == 'charging')) return false;
      if (_typeFilter == 'بيع' &&
          !(e['kind'] == 'tx' && data['type'] == 'sale')) return false;
      // البحث بالاسم
      if (_searchQuery.isNotEmpty) {
        final name = (data['customer_name'] ?? '').toString();
        if (!name.contains(_searchQuery)) return false;
      }
      return true;
    }).toList();
  }

  // ملخصا الفترة المعروضة (يتبعان الفلترة)
  double get _visibleSales {
    double sum = 0;
    for (final e in _visible) {
      if (e['kind'] == 'tx') {
        sum += double.tryParse(
            (e['data'] as Map)['amount_due']?.toString() ?? '0') ??
            0;
      }
    }
    return sum;
  }

  double get _visibleDeposits {
    double sum = 0;
    for (final e in _visible) {
      if (e['kind'] == 'pay') {
        sum += double.tryParse(
            (e['data'] as Map)['amount']?.toString() ?? '0') ??
            0;
      }
    }
    return sum;
  }

  String _fmtDateTime(dynamic value) {
    final dt = DateTime.tryParse((value ?? '').toString());
    if (dt == null) return '';
    final l = dt.toLocal();
    return '${l.year}/${l.month.toString().padLeft(2, '0')}/${l.day.toString().padLeft(2, '0')} — ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text('سجل العمليات',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF555555))),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomSearchBar(
                  hintText: 'ابحث باسم العميل...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(height: 14),

              // فلاتر الفترة
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['يومي', 'اسبوعي', 'شهري', 'الكل'].map((f) {
                  final selected = _periodFilter == f;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () => setState(() => _periodFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF166534)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                color:
                                selected ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // فلاتر النوع
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['الكل', 'شحن', 'بيع', 'إيداعات'].map((f) {
                  final selected = _typeFilter == f;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () => setState(() => _typeFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1B8ED8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                color:
                                selected ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // بطاقات الملخص (تتبع الفلترة)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: _summaryCard('قيمة العمليات',
                            _visibleSales.toStringAsFixed(0), Colors.blue)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _summaryCard('الإيداعات',
                            _visibleDeposits.toStringAsFixed(0),
                            Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Divider(thickness: 1, indent: 20, endIndent: 20),

              // السجل
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : _visible.isEmpty
                    ? const Center(
                    child: Text('لا توجد عمليات في هذه الفترة'))
                    : RefreshIndicator(
                  onRefresh: _fetchAll,
                  child: ListView.builder(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: _visible.length,
                    itemBuilder: (context, index) {
                      final e = _visible[index];
                      return e['kind'] == 'pay'
                          ? _paymentCard(e['data'])
                          : _transactionCard(e['data']);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 6),
          Text('$amount ₪',
              style: TextStyle(
                  color: color, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // بطاقة عملية (شحن/بيع)
  Widget _transactionCard(Map<String, dynamic> t) {
    final double due =
        double.tryParse(t['amount_due']?.toString() ?? '0') ?? 0;
    final double paid =
        double.tryParse(t['amount_paid']?.toString() ?? '0') ?? 0;
    final bool isCharging = t['type']?.toString() == 'charging';
    final String typeLabel = isCharging ? 'شحن' : 'بيع';
    final String name = t['customer_name']?.toString() ?? '';
    final String product = t['product_name']?.toString() ?? '';
    final int qty = int.tryParse(t['quantity']?.toString() ?? '1') ?? 1;

    return InkWell(
      onTap: () => _showTxDetails(t),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isCharging
                  ? Colors.blue.shade100
                  : Colors.orange.shade100,
              width: 1.2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
              isCharging ? Colors.blue.shade50 : Colors.orange.shade50,
              child: Icon(
                  isCharging
                      ? Icons.battery_charging_full
                      : Icons.shopping_cart,
                  size: 18,
                  color: isCharging ? Colors.blue : Colors.orange),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                      '$product${qty > 1 ? ' ×$qty' : ''} ($typeLabel)',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  Text(_fmtDateTime(t['received_at'] ?? t['date']),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${due.toStringAsFixed(2)} ₪',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  paid >= due ? 'مدفوع' : 'مدفوع: ${paid.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: paid >= due ? Colors.green : Colors.orange,
                      fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة إيداع (خضراء)
  Widget _paymentCard(Map<String, dynamic> p) {
    final double amount =
        double.tryParse(p['amount']?.toString() ?? '0') ?? 0;
    final String name = p['customer_name']?.toString() ?? '';
    final String note = p['note']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green.shade100,
            child: const Icon(Icons.payments_outlined,
                size: 18, color: Colors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(note.trim().isNotEmpty ? note : 'إيداع / سداد',
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(_fmtDateTime(p['paid_at']),
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text('+ ${amount.toStringAsFixed(2)} ₪',
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }

  void _showTxDetails(Map<String, dynamic> t) {
    final double due =
        double.tryParse(t['amount_due']?.toString() ?? '0') ?? 0;
    final double paid =
        double.tryParse(t['amount_paid']?.toString() ?? '0') ?? 0;
    final double remaining = due - paid;
    final bool delivered = t['status']?.toString() == 'delivered';

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          title: Text(
            '${t['customer_name'] ?? ''} — ${t['product_name'] ?? ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('النوع',
                  t['type']?.toString() == 'sale' ? 'بيع مباشر' : 'شحن جهاز'),
              _row('الكمية', t['quantity']?.toString() ?? '1'),
              _row('السعر', '${due.toStringAsFixed(2)} ₪'),
              _row('المدفوع', '${paid.toStringAsFixed(2)} ₪'),
              _row('المتبقي',
                  '${remaining > 0 ? remaining.toStringAsFixed(2) : '0.00'} ₪',
                  color: remaining > 0 ? Colors.red : Colors.green),
              if (t['shelf_number'] != null)
                _row('الرف', t['shelf_number'].toString()),
              const Divider(),
              _row('الاستلام', _fmtDateTime(t['received_at'] ?? t['date'])),
              _row('الحالة', delivered ? 'تم التسليم ✅' : 'قيد الشحن ⏳'),
              if (delivered)
                _row('التسليم', _fmtDateTime(t['delivered_at'])),
            ],
          ),
          actions: [
            Center(
                child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'))),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}