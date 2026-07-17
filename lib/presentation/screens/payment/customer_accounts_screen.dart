import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/customers/customers_cubit.dart';
import '../../../logic/customers/customers_state.dart';
import '../../../widgets/common_widgets.dart';

class CustomerAccountsScreen extends StatefulWidget {
  const CustomerAccountsScreen({super.key});

  @override
  State<CustomerAccountsScreen> createState() => _CustomerAccountsScreenState();
}

class _CustomerAccountsScreenState extends State<CustomerAccountsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filtered = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CustomersCubit>().getCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CustomersCubit, CustomersState>(
          listener: (context, state) {
            if (state is CustomersSuccess) {
              setState(() => _filtered = state.customers);
            }
            if (state is CustomersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMsg), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildTopBar(),
                _buildTitle(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF03AED2), width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlign: TextAlign.right,
                      onChanged: (val) {
                        if (state is CustomersSuccess) {
                          setState(() {
                            _filtered = state.customers
                                .where((c) => c['name'].toString().contains(val))
                                .toList();
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن عميل...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: state is CustomersLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filtered.isEmpty
                      ? const Center(child: Text('لا يوجد عملاء'))
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final customer = _filtered[index];
                      final double balance = double.tryParse(
                          customer['balance']?.toString() ?? '0') ?? 0;
                      final String name = customer['name'] ?? '';
                      final String initials = name.isNotEmpty ? name[0] : '?';

                      return InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/transaction-debt',
                          arguments: {
                            'customerId': customer['id'].toString(),
                            'customerName': name,
                          },
                        ),
                        child: CustomerCard(
                          name: name,
                          balance: balance.toStringAsFixed(2),
                          initials: initials,
                          hasDebt: balance < 0,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, color: Colors.grey),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'حسابات العملاء',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/icons/logo.png',
            width: 30, height: 30,
            errorBuilder: (_, __, ___) =>  Image.asset("assets/icons/logo.png", width: 35, height: 35),
          ),
        ],
      ),
    );
  }
}

// ── كارت العميل ──
class CustomerCard extends StatelessWidget {
  final String name;
  final String balance;
  final String initials;
  final bool hasDebt;

  const CustomerCard({
    super.key,
    required this.name,
    required this.balance,
    required this.initials,
    required this.hasDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('رصيد', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                balance,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: hasDebt ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: hasDebt
                ? Colors.red.withOpacity(0.1)
                : const Color(0xFF00E676).withOpacity(0.1),
            child: Text(
              initials,
              style: TextStyle(
                color: hasDebt ? Colors.red : const Color(0xFF00C853),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}