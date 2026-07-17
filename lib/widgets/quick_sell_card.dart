import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/app_theme.dart';

class QuickSellCard extends StatelessWidget {
  const QuickSellCard({
    super.key,
    required this.customerName,
    required this.customerId,
    required this.balance,
    required this.lastTransactions,
    this.onSell,
  });

  final String customerName;
  final String customerId;
  final double balance;
  final List<dynamic> lastTransactions;
  final VoidCallback? onSell;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.rounded15,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // رأس الكرت
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر البيع السريع
              GestureDetector(
                onTap: onSell,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppGradients.homeCard,
                    borderRadius: AppBorderRadius.rounded10,
                  ),
                  child: const Text(
                    'بيع سريع',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // معلومات العميل
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'الرصيد: ${balance.toStringAsFixed(2)} ₪',
                        style: TextStyle(
                          color: balance < 0 ? Colors.red : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // آخر العمليات
          lastTransactions.isEmpty
              ? const Text(
            'لا يوجد عمليات سابقة',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
              : Column(
            children: lastTransactions.take(3).map((t) {
              final amount = double.tryParse(t['amount_paid']?.toString() ?? '0') ?? 0;
              final productName = t['product_name'] ?? 'عملية';
              final date = t['created_at']?.toString().substring(0, 10) ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${amount.toStringAsFixed(2)} ₪',
                      style: TextStyle(
                        color: amount >= 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          date,
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          productName,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}