import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/customers/customers_cubit.dart';
import '../logic/customers/customers_state.dart';
import '../utils/app_theme.dart';

class DepositDialog extends StatefulWidget {
  const DepositDialog({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  final String customerName;
  final String customerId;

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomersCubit, CustomersState>(
      listener: (context, state) {
        if (state is PayDebtSuccess) {
          Navigator.pop(context); // إغلاق الديالوج
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الإيداع بنجاح ✅'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CustomersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMsg), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Container(
          width: 253,
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.rounded20,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Icon(Icons.payments_outlined, size: 40, color: Colors.blue.shade400),
              const SizedBox(height: 8),
              const Text(
                'إيداع رصيد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3A3B3B)),
              ),
              Text(
                'للعميل "${widget.customerName}"',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 15),

              // حقل إدخال المبلغ
              Container(
                width: 178,
                height: 51,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFFBF).withOpacity(0.5),
                  borderRadius: AppBorderRadius.rounded15,
                  border: Border.all(color: const Color(0xFFCCFFBF)),
                ),
                child: Center(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: TextStyle(color: Colors.green, fontSize: 22),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DialogButton(
                      label: state is CustomersLoading ? '...' : 'تأكيد الإيداع',
                      width: 100,
                      bgColor: const Color(0xFFCCFFBF),
                      textColor: Colors.green,
                      onTap: state is CustomersLoading
                          ? () {}
                          : () {
                        final amount = double.tryParse(_amountController.text) ?? 0;
                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
                          );
                          return;
                        }
                        context.read<CustomersCubit>().payDebt(
                          widget.customerId,
                          amount,
                          'إيداع رصيد',
                        );
                      },
                    ),
                    _DialogButton(
                      label: 'إلغاء',
                      width: 80,
                      bgColor: Colors.white,
                      textColor: Colors.blue.shade700,
                      borderColor: Colors.blue.shade300,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.width,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final double width;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(11.5),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: bgColor == const Color(0xFFCCFFBF)
              ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}