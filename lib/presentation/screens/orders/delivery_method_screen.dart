import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../widgets/common_widgets.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home:DeliveryMethodScreen (),
  ));
}

class DeliveryMethodScreen extends StatefulWidget {
  const DeliveryMethodScreen({super.key});

  @override
  State<DeliveryMethodScreen> createState() => _DeliveryMethodScreenState();
}

class _DeliveryMethodScreenState extends State<DeliveryMethodScreen> {
  String? _selectedMethod;

  // TODO: أضف طرق الاستلام هنا
  static const _methods = [
    'عند الاستلام',
    'مسبق الدفع',
    // أضف المزيد حسب الحاجة
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'طريقة التسليم',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: const AppBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TODO: أضف المحتوى هنا
            Expanded(
              child: ListView.separated(
                itemCount: _methods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  final isSelected = _selectedMethod == method;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedMethod = method),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppBorderRadius.rounded12,
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(method,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              )),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.primaryBlue),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            PrimaryButton(
              label: 'تأكيد',
              onPressed: () {
                // TODO: handle selection
              },
            ),
          ],
        ),
      ),
    );
  }
}
