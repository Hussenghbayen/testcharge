import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomersScreen(),
    );
  }
}

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customers = [
      Customer("محمد مهدي", "0591231231", 10),
      Customer("أحمد محمود", "0599999999", 20),
      Customer("خالد علي", "0598888888", 5),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            return CustomerCard(
              customer: customers[index],
              onTap: () {
                debugPrint("Pressed: ${customers[index].name}");
              },
            );
          },
        ),
      ),
    );
  }
}

/// 🔥 موديل
class Customer {
  final String name;
  final String phone;
  final double balance;

  Customer(this.name, this.phone, this.balance);
}

/// 🔥 الكارد الكامل
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  /// أول حرفين من الاسم
  String getInitials(String name) {
    final parts = name.split(" ");
    if (parts.length == 1) return parts[0][0];
    return parts[0][0] + parts[1][0];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [

            /// 🟢 الدائرة (يسار)
            Container(
              width: 29,
              height: 29,
              decoration: const BoxDecoration(
                color: Color(0xFF00FFAE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  getInitials(customer.name),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Spacer(),

            /// 🧾 الاسم + الرقم (بالنص)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  customer.phone,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// 💰 الرصيد (يمين)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("رصيد", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text("${customer.balance}\$"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}