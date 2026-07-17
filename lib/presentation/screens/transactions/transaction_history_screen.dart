import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/customers/customers_cubit.dart';
import '../../../logic/customers/customers_state.dart';
import '../../../widgets/common_widgets.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const TransactionHistoryScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<CustomersCubit>().getCustomerDetails(widget.customerId),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: BlocConsumer<CustomersCubit, CustomersState>(
        listener: (context, state) {
          if (state is PayDebtSuccess) {
            context.read<CustomersCubit>().getCustomerDetails(widget.customerId);
          }
          if (state is CustomersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMsg), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          List transactions = [];
          double balance = 0;

          if (state is CustomerDetailSuccess) {
            transactions = state.customer['transactions'] ?? [];
            balance = double.tryParse(state.customer['balance']?.toString() ?? '0') ?? 0;
          }

          return Column(
            children: [
              const Text(
                'سجل العمليات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomSearchBar(),
              ),
              const SizedBox(height: 20),
              _buildCustomerHeader(context),
              const SizedBox(height: 15),
              _buildBalanceCards(balance),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(indent: 25, endIndent: 25, thickness: 1),
              ),
              Expanded(
                child: state is CustomersLoading
                    ? const Center(child: CircularProgressIndicator())
                    : transactions.isEmpty
                    ? const Center(child: Text('لا توجد عمليات'))
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) =>
                      _buildTransactionItem(context, transactions[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/icons/logo.png',
            width: 30, height: 30,
            errorBuilder: (_, __, ___) =>
                Image.asset("assets/icons/logo.png", width: 35, height: 35),          ),
        ),
      ],
    );
  }

  Widget _buildCustomerHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _showDepositDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF62D344),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('إيداع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(widget.customerName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('أدوات الرصيد والديون',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCards(double balance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _cardItem('الرصيد', balance > 0 ? balance.toStringAsFixed(2) : '0', Colors.green),
          const SizedBox(width: 15),
          _cardItem('الدين', balance < 0 ? balance.abs().toStringAsFixed(2) : '0', Colors.red),
        ],
      ),
    );
  }

  Widget _cardItem(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Map<String, dynamic> t) {
    final double amount = double.tryParse(t['amount_paid']?.toString() ?? '0') ?? 0;
    final bool isPositive = t['payment_status'] == 'paid' || amount > 0;
    final String productName = t['product_name'] ?? 'عملية';
    final String date = (t['created_at'] ?? '').toString().length >= 10
        ? t['created_at'].toString().substring(0, 10)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.grey, size: 22),
              const SizedBox(width: 5),
              Text(
                isPositive
                    ? '${amount.toStringAsFixed(0)}+'
                    : '${amount.abs().toStringAsFixed(0)}-',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 12,
                backgroundColor: isPositive ? Colors.green : Colors.red,
                child: Icon(
                  isPositive ? Icons.add : Icons.arrow_downward,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ديالوج الإيداع ──
  void _showDepositDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet, size: 30, color: Colors.green),
              const SizedBox(height: 10),
              const Text('إيداع رصيد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text('للعميل "${widget.customerName}"',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'أدخل المبلغ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ملاحظة (اختياري)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (amount > 0) {
                          context.read<CustomersCubit>().payDebt(
                            widget.customerId,
                            amount,
                            noteController.text,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2FBE5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: const Center(
                          child: Text('تأكيد الإيداع',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('إلغاء'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ديالوج الحذف ──
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('حذف العميل',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
              const SizedBox(height: 15),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'Tajawal'),
                  children: [
                    const TextSpan(text: 'هل أنت متأكد من '),
                    const TextSpan(text: 'حذف ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    const TextSpan(text: 'العميل '),
                    TextSpan(
                      text: '"${widget.customerName}"',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '؟\nسيتم حذف جميع العمليات أيضاً'),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<CustomersCubit>().deleteCustomer(widget.customerId);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: 140, height: 45,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: const Center(
                    child: Text('حذف', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}