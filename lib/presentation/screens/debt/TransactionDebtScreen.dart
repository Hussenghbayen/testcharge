import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/customers/customers_cubit.dart';
import '../../../logic/customers/customers_state.dart';

class TransactionDebtScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const TransactionDebtScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<TransactionDebtScreen> createState() => _TransactionDebtScreenState();
}

class _TransactionDebtScreenState extends State<TransactionDebtScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<CustomersCubit>().getCustomerDetails(widget.customerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: BlocConsumer<CustomersCubit, CustomersState>(
            listener: (context, state) {
              if (state is PayDebtSuccess) {
                // بعد الإيداع، أعد تحميل البيانات
                context.read<CustomersCubit>().getCustomerDetails(widget.customerId);
              }
              if (state is CustomersError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMsg), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              // استخرج البيانات إذا موجودة
              Map<String, dynamic>? customer;
              List transactions = [];
              double balance = 0;

              if (state is CustomerDetailSuccess) {
                customer = state.customer;
                transactions = customer?['transactions'] ?? [];
                balance = double.tryParse(customer?['balance'].toString() ?? '0') ?? 0;
              }

              return Column(
                children: [
                  const SizedBox(height: 10),

                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.customerName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // BALANCE CARDS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _cardItem(
                            'الرصيد',
                            balance > 0 ? balance.toStringAsFixed(2) : '0',
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _cardItem(
                            'الدين',
                            balance < 0 ? balance.abs().toStringAsFixed(2) : '0',
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: Colors.grey.shade400, thickness: 1),
                  ),
                  const SizedBox(height: 10),

                  // LIST
                  Expanded(
                    child: state is CustomersLoading
                        ? const Center(child: CircularProgressIndicator())
                        : transactions.isEmpty
                        ? const Center(child: Text('لا توجد عمليات'))
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        return _buildTransactionItem(t);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _cardItem(String title, String value, Color color) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> t) {
    final double amountPaid = double.tryParse(t['amount_paid']?.toString() ?? '0') ?? 0;
    final String productName = t['product_name'] ?? 'عملية';
    final String date = (t['created_at'] ?? '').toString().length >= 10
        ? t['created_at'].toString().substring(0, 10)
        : '';
    final bool isDebt = t['payment_status'] == 'debt';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.grey.shade500, size: 18),
              const SizedBox(width: 6),
              Text(
                isDebt ? '-${amountPaid.toStringAsFixed(0)}' : amountPaid.toStringAsFixed(0),
                style: TextStyle(
                  color: isDebt ? Colors.red : Colors.green,
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
                  Text(productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF444444))),
                  const SizedBox(height: 4),
                  Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDebt ? const Color(0xFFFF5A5A) : Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDebt ? Icons.arrow_downward : Icons.arrow_upward,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet, size: 40, color: Colors.green),
              const SizedBox(height: 10),
              const Text('إيداع رصيد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text('للعميل "${widget.customerName}"', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                    child: ElevatedButton(
                      onPressed: () {
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2FBE5),
                        foregroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('تأكيد الإيداع', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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
}