import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

// TODO: implement new device registration card
// كرت تسجيل جهاز جديد — يظهر عند إضافة جهاز للرف

class NewDeviceCard extends StatelessWidget {
  const NewDeviceCard({
    super.key,
    required this.deviceName,
    required this.customerName,
    required this.shelfNumber,
    required this.price,
    required this.paymentMethod,
    this.onConfirm,
    this.onCancel,
  });

  final String deviceName;
  final String customerName;
  final int shelfNumber;
  final double price;
  final String paymentMethod;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.rounded15,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // رأس الكرت
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // رقم الرف
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  gradient: AppGradients.blueNavy,
                  borderRadius: AppBorderRadius.rounded10,
                ),
                child: Center(
                  child: Text('رف\n$shelfNumber',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.1)),
                ),
              ),

              // معلومات الجهاز
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(customerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(deviceName,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // تفاصيل الدفع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${price.toStringAsFixed(2)} ₪',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue)),
              Text(paymentMethod,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 16),

          // أزرار
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: AppBorderRadius.rounded10,
                    ),
                    child: const Center(
                        child: Text('إلغاء',
                            style: TextStyle(color: Colors.grey))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: AppGradients.blueNavy,
                      borderRadius: AppBorderRadius.rounded10,
                    ),
                    child: const Center(
                        child: Text('تثبيت في الرف',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
