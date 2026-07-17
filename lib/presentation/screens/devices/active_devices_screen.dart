import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../logic/devices/devices_cubit.dart';
import '../../../logic/devices/devices_state.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/adddevicebottomsheet.dart';
import '../../../logic/transactions/transactions_cubit.dart';

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
  );
  static const LinearGradient activeCardGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF1E3A8A)],
  );
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF66EB00), Color(0xFF389700)],
  );
}

class ActiveDevicesScreen extends StatefulWidget {
  const ActiveDevicesScreen({super.key});

  @override
  State<ActiveDevicesScreen> createState() => _ActiveDevicesScreenState();
}

class _ActiveDevicesScreenState extends State<ActiveDevicesScreen> {
  List<dynamic> _allDevices = [];
  List<dynamic> _filtered = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
            () => context.read<DevicesCubit>().getOccupiedShelves());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: BlocConsumer<DevicesCubit, DevicesState>(
          listener: (context, state) {
            if (state is DevicesLoaded) {
              setState(() {
                _allDevices = state.occupiedShelves;
                _filtered = state.occupiedShelves;
              });
            }
            if (state is DevicesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.errorMsg),
                    backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildTopBar(context),
                const Text(
                  'الأجهزة النشطة',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A3B3B)),
                ),
                const SizedBox(height: 10),
                CustomSearchBar(
                  hintText: 'ابحث عن عميل...',
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _filtered = _allDevices
                          .where((d) => d['customer_name']
                          .toString()
                          .contains(val))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: state is DevicesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filtered.isEmpty
                      ? const Center(
                      child: Text('لا توجد أجهزة نشطة'))
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18),
                    itemCount: _filtered.length,
                    itemBuilder: (_, index) => DeviceCard(
                      device: _filtered[index],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child:
            const Icon(Icons.arrow_back, color: Colors.black54),
          ),
          Image.asset('assets/icons/logo.png',
              width: 30, height: 30),
        ],
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;
  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final String customerName = device['customer_name'] ?? '';
    final String productName = device['product_name'] ?? '';
    final String shelfNumber =
        device['shelf_number']?.toString() ?? '';
    final double remaining = double.tryParse(
        device['remaining_debt']?.toString() ?? '0') ??
        0;

    final String paymentLabel =
    remaining <= 0 ? 'مدفوع' : 'متبقي عليه';

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _showDeliveryDialog(context, device),
            child: Container(
              width: 56,
              height: 34,
              decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: const Center(
                  child: Text('تسليم',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                size: 24, color: Color(0xFF3A3B3B)),
            onPressed: () => _openAddDeviceSheet(context),
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(customerName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A3B3B))),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(productName,
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey)),
                  const SizedBox(width: 4),
                  const Icon(Icons.smartphone,
                      size: 12, color: Colors.black),
                ],
              ),
              const SizedBox(height: 2),
              _TagBox(
                  label: paymentLabel,
                  width: 65,
                  bgColor: remaining <= 0
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  textColor: remaining <= 0
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100)),
              const SizedBox(height: 2),
              _TagBox(
                  label: '${remaining.toStringAsFixed(0)} ش',
                  width: 50,
                  bgColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: Colors.grey),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
                gradient: AppGradients.activeCardGradient,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                'رف\n$shelfNumber',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // فتح نافذة إضافة الجهاز الموحّدة (نفس نافذة الرئيسية)
  void _openAddDeviceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<TransactionsCubit>(),
        child: const AddDeviceBottomSheet(),
      ),
    );
  }

  // ===== نافذة التسليم الذكية =====
  void _showDeliveryDialog(
      BuildContext context, Map<String, dynamic> device) {
    final String transactionId =
        device['transaction_id']?.toString() ?? '';
    final String customerName = device['customer_name'] ?? '';
    final String productName = device['product_name'] ?? '';

    // رصيد العميل الكلي (سالب = عليه دين، موجب = له رصيد)
    final double balance = double.tryParse(
        device['customer_balance']?.toString() ?? '0') ??
        0;
    final double remaining = balance < 0 ? -balance : 0; // دينه الكلي

    final amountController = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          Future<void> deliver() async {
            final paidNow =
                double.tryParse(amountController.text) ?? 0;
            if (paidNow < 0) return;
            setDialogState(() => saving = true);
            try {
              final token = await FirebaseAuth.instance.currentUser
                  ?.getIdToken();
              final response = await http.put(
                Uri.parse(
                    'https://charging-api-tkne.onrender.com/api/transactions/$transactionId/deliver'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode({"amount_paid": paidNow}),
              );
              if (response.statusCode == 200) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم تسليم الجهاز بنجاح ✅'),
                      backgroundColor: Colors.green),
                );
                // تحديث القائمة
                context.read<DevicesCubit>().getOccupiedShelves();
              } else {
                final data = jsonDecode(response.body);
                setDialogState(() => saving = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(data['message']?.toString() ??
                          'فشل التسليم'),
                      backgroundColor: Colors.red),
                );
              }
            } catch (e) {
              setDialogState(() => saving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('خطأ في الاتصال بالسيرفر'),
                    backgroundColor: Colors.red),
              );
            }
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('تسليم جهاز — $customerName',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(productName,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 15),

                    // رصيد الزبون — يُعرض دائماً كما هو
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: balance < 0
                            ? const Color(0xFFFFF3E0)
                            : balance > 0
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        balance < 0
                            ? 'رصيده: ${balance.toStringAsFixed(2)} ₪ (عليه دين)'
                            : balance > 0
                            ? 'رصيده: +${balance.toStringAsFixed(2)} ₪ (له رصيد)'
                            : 'رصيده: 0 ₪ (متعادل)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: balance < 0
                              ? const Color(0xFFE65100)
                              : balance > 0
                              ? const Color(0xFF2E7D32)
                              : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // دفع الآن
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'دفع الآن (اختياري)',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _quickBtn(
                              'لم يدفع', Colors.orange, () {
                            setDialogState(() =>
                            amountController.text = '0');
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _quickBtn(
                            remaining > 0
                                ? 'سداد كامل (${remaining.toStringAsFixed(0)})'
                                : 'سداد كامل',
                            Colors.green,
                            remaining > 0
                                ? () {
                              setDialogState(() =>
                              amountController.text =
                                  remaining
                                      .toStringAsFixed(2));
                            }
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: saving
                                ? null
                                : () => Navigator.pop(dialogCtx),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                              ),
                              alignment: Alignment.center,
                              child: const Text('إلغاء',
                                  style: TextStyle(
                                      fontWeight:
                                      FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: saving ? null : deliver,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient:
                                AppGradients.greenGradient,
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: saving
                                  ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                  CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                                  : const Text('تسليم',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _quickBtn(
      String label, Color color, VoidCallback? onTap) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.shade200
              : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color:
              disabled ? Colors.grey.shade300 : color,
              width: 1),
        ),
        child: Text(label,
            style: TextStyle(
                color: disabled ? Colors.grey : color,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }
}

class _TagBox extends StatelessWidget {
  const _TagBox(
      {required this.label,
        required this.width,
        required this.bgColor,
        required this.textColor,
        this.borderColor});
  final String label;
  final double width;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 18,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 0.5)
            : null,
      ),
      child: Center(
          child: Text(label,
              style: TextStyle(fontSize: 9, color: textColor))),
    );
  }
}