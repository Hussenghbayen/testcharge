import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/customers/customers_cubit.dart';
import '../../../logic/customers/customers_state.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerDetailsScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<CustomersCubit>().getCustomerDetails(widget.customerId));
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'مدفوع';
      case 'partial':
        return 'جزئي';
      case 'debt':
        return 'دين';
      default:
        return status;
    }
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return '—';
    final dt = DateTime.tryParse(value.toString());
    if (dt == null) return value.toString();
    final local = dt.toLocal();
    final d =
        '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
    final t =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$d — $t';
  }

  String _shortDate(dynamic value) {
    if (value == null) return '';
    final dt = DateTime.tryParse(value.toString());
    if (dt == null) return value.toString();
    final local = dt.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              Image.asset("assets/icons/logo.png", width: 35, height: 35),
            ),
          ],
        ),
        body: BlocBuilder<CustomersCubit, CustomersState>(
          builder: (context, state) {
            if (state is CustomersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CustomersError) {
              return Center(child: Text(state.errorMsg));
            }
            if (state is CustomerDetailSuccess) {
              final data = state.customer;
              final customer =
                  (data['customer'] as Map<String, dynamic>?) ?? data;
              final transactions = data['transactions'] as List? ?? [];
              final payments = data['payments'] as List? ?? [];
              final balance =
                  double.tryParse(customer['balance']?.toString() ?? '0') ??
                      0;

              // كشف حساب موحّد: دمج العمليات والإيداعات وترتيبها بالتاريخ
              final List<Map<String, dynamic>> timeline = [
                ...transactions.map((t) => {
                  'kind': 'tx',
                  'when': DateTime.tryParse(
                      (t['received_at'] ?? t['date'] ?? '')
                          .toString()) ??
                      DateTime(2000),
                  'data': t as Map<String, dynamic>,
                }),
                ...payments.map((p) => {
                  'kind': 'pay',
                  'when': DateTime.tryParse(
                      (p['paid_at'] ?? '').toString()) ??
                      DateTime(2000),
                  'data': p as Map<String, dynamic>,
                }),
              ]..sort((a, b) =>
                  (b['when'] as DateTime).compareTo(a['when'] as DateTime));

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showDepositDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("إيداع"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        Text(
                          customer['name'] ?? widget.customerName,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSummaryCard(
                          "الدين",
                          balance < 0 ? balance.abs().toStringAsFixed(2) : '0',
                          Colors.red,
                        ),
                        const SizedBox(width: 15),
                        _buildSummaryCard(
                          "الرصيد",
                          balance > 0 ? balance.toStringAsFixed(2) : '0',
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const SizedBox(height: 10),
                    timeline.isEmpty
                        ? const Text('لا يوجد عمليات',
                        style: TextStyle(color: Colors.grey))
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: timeline.length,
                      itemBuilder: (context, index) {
                        final entry = timeline[index];
                        final item =
                        entry['data'] as Map<String, dynamic>;
                        return entry['kind'] == 'pay'
                            ? _buildPaymentItem(item)
                            : _buildTransactionItem(item);
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إيداع مبلغ', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              context.read<CustomersCubit>().payDebt(
                widget.customerId,
                amount,
                noteController.text,
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> t) {
    final due = double.tryParse(t['amount_due']?.toString() ?? '0') ?? 0;
    final paid = double.tryParse(t['amount_paid']?.toString() ?? '0') ?? 0;
    final remaining = due - paid;
    final title = t['product_name']?.toString() ?? 'عملية';
    final date = _shortDate(t['received_at'] ?? t['date']);
    final status = _statusLabel(t['payment_status']?.toString() ?? '');
    final fullyPaid = remaining <= 0;

    return GestureDetector(
      onTap: () => _showTransactionDetails(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            const Icon(Icons.edit_note, color: Colors.grey),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${due.toStringAsFixed(2)} ₪',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  fullyPaid
                      ? 'مدفوع بالكامل'
                      : 'مدفوع: ${paid.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: fullyPaid ? Colors.green : Colors.orange,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date,
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(status,
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 15),
            CircleAvatar(
              radius: 12,
              backgroundColor: fullyPaid ? Colors.green : Colors.red,
              child: Icon(
                fullyPaid ? Icons.check : Icons.remove,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة إيداع/سداد في كشف الحساب (خضراء)
  Widget _buildPaymentItem(Map<String, dynamic> p) {
    final amount = double.tryParse(p['amount']?.toString() ?? '0') ?? 0;
    final date = _shortDate(p['paid_at']);
    final note = p['note']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _showPaymentDetails(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.shade200, width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(Icons.payments_outlined, color: Colors.green),
            const SizedBox(width: 5),
            Text(
              '+ ${amount.toStringAsFixed(2)} ₪',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('إيداع / سداد',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(date,
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
                if (note.trim().isNotEmpty)
                  Text(note,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 15),
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.green,
              child: Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> p) {
    final amount = double.tryParse(p['amount']?.toString() ?? '0') ?? 0;
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('تفاصيل الإيداع',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('المبلغ', '+ ${amount.toStringAsFixed(2)} ₪',
                  valueColor: Colors.green),
              _detailRow('التاريخ والوقت', _formatDateTime(p['paid_at'])),
              if (p['note'] != null && p['note'].toString().trim().isNotEmpty)
                _detailRow('ملاحظة', p['note'].toString()),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> t) {
    final due = double.tryParse(t['amount_due']?.toString() ?? '0') ?? 0;
    final paid = double.tryParse(t['amount_paid']?.toString() ?? '0') ?? 0;
    final remaining = due - paid;
    final type =
    t['type']?.toString() == 'sale' ? 'بيع مباشر' : 'شحن جهاز';
    final delivered = t['status']?.toString() == 'delivered';

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            t['product_name']?.toString() ?? 'تفاصيل العملية',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('النوع', type),
                _detailRow('السعر', '${due.toStringAsFixed(2)} ₪'),
                _detailRow('المدفوع', '${paid.toStringAsFixed(2)} ₪'),
                _detailRow(
                  'المتبقي',
                  '${remaining > 0 ? remaining.toStringAsFixed(2) : '0.00'} ₪',
                  valueColor: remaining > 0 ? Colors.red : Colors.green,
                ),
                _detailRow('حالة الدفع',
                    _statusLabel(t['payment_status']?.toString() ?? '')),
                _detailRow('الكمية', t['quantity']?.toString() ?? '1'),
                const Divider(),
                _detailRow('تاريخ الاستلام',
                    _formatDateTime(t['received_at'] ?? t['date'])),
                _detailRow(
                  'حالة الجهاز',
                  delivered ? 'تم التسليم ✅' : 'قيد الشحن ⏳',
                ),
                if (delivered)
                  _detailRow(
                      'تاريخ التسليم', _formatDateTime(t['delivered_at'])),
                if (t['notes'] != null &&
                    t['notes'].toString().trim().isNotEmpty)
                  _detailRow('ملاحظات', t['notes'].toString()),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}