import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/customers/customers_cubit.dart';
import '../../../logic/customers/customers_state.dart';
import '../../../logic/dashboard/dashboard_cubit.dart';
import '../../../logic/dashboard/dashboard_state.dart';
import '../../../logic/products/products_cubit.dart';
import '../../../logic/products/products_state.dart';
import '../../../logic/shelves/Shelves_State.dart';
import '../../../logic/shelves/shelves_cubit.dart';
import '../../../logic/transactions/transactions_cubit.dart';
import '../../../widgets/adddevicebottomsheet.dart';
import '../../../widgets/quick_sale_bottom_sheet.dart';
import '../../../widgets/common_widgets.dart';
import '../debt/DebtsScreen.dart';
import '../debt/customer_details_screen.dart';
import '../devices/active_devices_screen.dart';
import '../history/HistoryReportScreen.dart';
import '../payment/customer_accounts_screen.dart';
import '../product/Product management screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ================= HOME SCREEN =================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 2;

  final List<Widget> _pages = [
    const Historyreportscreen(),
    const DebtsScreen(),
    const _HomeContent(),
    const ActiveDevicesScreen(),
    const CustomerAccountsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const _AppDrawer(),
      body: _pages[_currentNavIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}

// ================= DRAWER =================
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF0F4FF),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset("assets/icons/logo.png", width: 35, height: 35),

              ),
              const SizedBox(height: 40),
              _DrawerItem(
                icon: Icons.card_giftcard_outlined,
                title: 'ادارة منتجات',
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _DrawerItem(
                icon: Icons.shelves,
                title: 'اضافة رفوف',
                onTap: () {
                  Navigator.pop(context);
                  _showAddShelfDialog(context);
                },
              ),
            ],
          ),
        ),
      ),

    );
  }

  // ===== Dialog إضافة منتجات =====
  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedType = 'sale';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, _, __) => BlocProvider.value(
        value: context.read<ProductsCubit>(),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: BlocConsumer<ProductsCubit, ProductsState>(
                      listener: (context, state) {
                        if (state is ProductsSuccess) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إضافة المنتج بنجاح ✅'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (state is ProductsError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMsg),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_giftcard_outlined,
                                    color: Color(0xFF0EA5E9), size: 22),
                                SizedBox(width: 8),
                                Text('اضافة منتج',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // نوع المنتج
                            const Text('نوع المنتج',
                                style: TextStyle(fontSize: 13, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setStateDialog(
                                            () => selectedType = 'sale'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selectedType == 'sale'
                                            ? const Color(0xFF0EA5E9)
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('بيع',
                                          style: TextStyle(
                                              color: selectedType == 'sale'
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setStateDialog(
                                            () => selectedType = 'charging'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selectedType == 'charging'
                                            ? const Color(0xFF0EA5E9)
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('شحن',
                                          style: TextStyle(
                                              color: selectedType == 'charging'
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // اسم المنتج
                            const Text('اسم المنتج',
                                style: TextStyle(fontSize: 13, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: nameController,
                                textAlign: TextAlign.right,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'مثلاً: كولا',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // السعر
                            const Text('سعر البيع',
                                style: TextStyle(fontSize: 13, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'مثلاً: 2.0',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // زر الإضافة
                            GestureDetector(
                              onTap: state is ProductsLoading
                                  ? null
                                  : () {
                                if (nameController.text.isEmpty ||
                                    priceController.text.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'يرجى تعبئة جميع الحقول')),
                                  );
                                  return;
                                }
                                context.read<ProductsCubit>().addProduct(
                                  nameController.text.trim(),
                                  selectedType,
                                  0,
                                  double.tryParse(priceController.text) ?? 0,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0EA5E9),
                                      Color(0xFF1E3A8A)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: state is ProductsLoading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('اضافة المنتج',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
    );
  }

// ===== Dialog إضافة رفوف =====
  void _showAddShelfDialog(BuildContext context) {
    final countController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, _, __) => BlocProvider.value(
        value: context.read<ShelvesCubit>(),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: BlocConsumer<ShelvesCubit, ShelvesState>(
                  listener: (context, state) {
                    if (state is ShelvesSuccess) {
                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إضافة الرفوف بنجاح ✅'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is ShelvesError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMsg),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shelves,
                                color: Color(0xFF0EA5E9), size: 22),
                            SizedBox(width: 8),
                            Text('اضافة رف',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('عدد الرفوف',
                            style:
                            TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: countController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'مثلاً: 10',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: state is ShelvesLoading
                              ? null
                              : () {
                            final count =
                            int.tryParse(countController.text);
                            if (count == null || count <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('أدخل عدد صحيح')),
                              );
                              return;
                            }
                            context
                                .read<ShelvesCubit>()
                                .addShelvesBulk(count);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0EA5E9),
                                  Color(0xFF1E3A8A)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: state is ShelvesLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('اضافة الرفوف',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

// ===== Drawer Item Widget =====
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE8F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Icon(icon, size: 36, color: const Color(0xFF1E3A8A)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= HOME CONTENT =================
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  List<dynamic> _allCustomers = [];
  List<dynamic> _filteredCustomers = [];
  int _selectedCategory = 0;
  int _activeCardIndex = 2;
  String _selectedDevice = 'جوال';
  String _searchQuery = '';

  static const _categories = ['جوال', 'باور', 'بطارية', 'لابتوب', 'سماعات'];
  static const _categoryIcons = [
    'assets/icons/phone.png',
    'assets/icons/powerbank.png',
    'assets/icons/battery.png',
    'assets/icons/laptop.png',
    'assets/icons/headphones.png',
  ];

  final LinearGradient _primaryGradient = const LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
  );

  final LinearGradient _activeCardGradient = const LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF1E3A8A)],
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardCubit>().getDashboard();
      context.read<CustomersCubit>().getCustomers();
    });
    Future.microtask(() => context.read<DashboardCubit>().getDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('ابدأ الشحن',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('حدد جهازك لبدء الشحن',
                  style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "الجهاز المختار: $_selectedDevice",
                style: const TextStyle(
                  color: Color(0xFF0EA5E9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCategories(),
            const SizedBox(height: 20),


            BlocListener<CustomersCubit, CustomersState>(
              listener: (context, state) {
                if (state is CustomersSuccess) {
                  setState(() {
                    _allCustomers = state.customers;
                    _filteredCustomers = state.customers;
                  });
                }
              },
              child: CustomSearchBar(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _filteredCustomers = _allCustomers
                        .where((c) => c['name'].toString().contains(val))
                        .toList();
                  });
                },
              ),
            ),
            if (_searchQuery.isNotEmpty && _filteredCustomers.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredCustomers.take(5).length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16),
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    return ListTile(
                      title: Text(
                        customer['name'] ?? '',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14),
                      ),
                        onTap: () {
                          FocusScope.of(context).unfocus(); // إغلاق الكيبورد
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailsScreen(
                                customerId: customer['id'].toString(),
                                customerName: customer['name']?.toString() ?? '',
                              ),
                            ),
                          );
                        },
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
            _buildInfoGrid(),
            const SizedBox(height: 25),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('مرحباً', style: TextStyle(color: Colors.grey)),
    Text(
    ((FirebaseAuth.instance.currentUser?.displayName ?? '').trim().isNotEmpty)
    ? FirebaseAuth.instance.currentUser!.displayName!
        : (FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'مستخدم'),
    style: const TextStyle(fontWeight: FontWeight.bold),
    ),
                ],
              ),
              const SizedBox(width: 10),
              const CircleAvatar(child: Icon(Icons.person)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: List.generate(_categories.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = i;
                  _selectedDevice = _categories[i];
                });
              },
              child: _CategoryItem(
                title: _categories[i],
                iconPath: _categoryIcons[i],
                isSelected: _selectedCategory == i,
                gradient: _primaryGradient,
              ),
            ),
          );
        }),
      ),
    );
  }



  Widget _buildInfoGrid() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        List<_InfoCardData> cards = [
          const _InfoCardData(title: 'ديون خارجية', value: '0'),
          const _InfoCardData(title: 'الأجهزة الآن', value: '0'),
          const _InfoCardData(title: 'الخزينة (كاش)', value: '0'),
          const _InfoCardData(title: 'أرصدة العملاء', value: '0'),
        ];
        if (state is DashboardSuccess) {
          cards = [
            _InfoCardData(title: 'ديون خارجية', value: state.totalDebts.toStringAsFixed(0)),
            _InfoCardData(title: 'الأجهزة الآن', value: state.occupiedShelves.toString()),
            _InfoCardData(title: 'الخزينة (كاش)', value: state.totalIncome.toStringAsFixed(0)),
            _InfoCardData(title: 'أرصدة العملاء', value: state.customerBalances.toStringAsFixed(0)),
          ];
        }

        return Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _activeCardIndex = index);

                    switch (cards[index].title) {
                      case 'ديون خارجية':
                        Navigator.pushNamed(context, '/debts');
                        break;

                      case 'الأجهزة الآن':
                        Navigator.pushNamed(context, '/active-devices');
                        break;

                      case 'الخزينة (كاش)':
                      // TODO: حدد الـ route الصحيح لشاشة الخزينة/الكاش
                      // مثال لو موجودة: Navigator.pushNamed(context, '/cash-treasury');
                        break;

                      case 'أرصدة العملاء':
                        Navigator.pushNamed(context, '/customer-accounts');
                        break;
                    }
                  },
                  child: HomeInfoCard(
                    title: cards[index].title,
                    value: cards[index].value,
                    isActive: _activeCardIndex == index,
                    activeGradient: _activeCardGradient,
                    iconPath: 'assets/icons/money.png',
                  ),
                );
              },
            ),
            if (state is DashboardLoading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }


  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              title: 'جهاز جديد',
              icon: Icons.add,
              isPrimary: true,
              gradient: _primaryGradient,
              onTap: _openAddDeviceSheet,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ActionButton(
              title: 'بيع سريع',
              icon: Icons.shopping_cart,
              isPrimary: false,
              gradient: _primaryGradient,
              onTap: _openQuickSellSheet,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddDeviceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => BlocProvider.value(
        value: context.read<TransactionsCubit>(),
        child: const AddDeviceBottomSheet(),
      ),
    ).then((_) {
      context.read<DashboardCubit>().getDashboard();
    });
  }

  void _openQuickSellSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CustomersCubit>()),
            BlocProvider.value(value: context.read<TransactionsCubit>()),
          ],
          child: const QuickSaleBottomSheet()
      ),
    ).then((_) {
      context.read<DashboardCubit>().getDashboard();
    });
  }
}

// ================= WIDGETS =================
class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.title,
    required this.iconPath,
    required this.isSelected,
    required this.gradient,
  });

  final String title;
  final String iconPath;
  final bool isSelected;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected ? gradient : null,
            color: isSelected ? null : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(iconPath),
          ),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}

class HomeInfoCard extends StatelessWidget {
  const HomeInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.isActive,
    required this.activeGradient,
    required this.iconPath,
  });

  final String title;
  final String value;
  final bool isActive;
  final Gradient activeGradient;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? null : Colors.white,
        gradient: isActive
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.19, 1.0],
          colors: [Color(0xFF0EA5E9), Color(0xFF1E3A8A)],
        )
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    iconPath,
                    width: 18,
                    height: 18,
                    color: isActive ? Colors.white : const Color(0xFF0EA5E9),
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.payments_outlined, size: 18),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 106,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.2)
                  : const Color(0xFF0EA5E9),
              borderRadius: BorderRadius.circular(10.5),
            ),
            child: const Text(
              'إظهار التفاصيل',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.gradient,
    this.onTap,
    this.isLoading = false,
  });

  final String title;
  final IconData icon;
  final bool isPrimary;
  final Gradient gradient;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: isPrimary ? gradient : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isPrimary ? Colors.white : Colors.black),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                    color: isPrimary ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCardData {
  const _InfoCardData({required this.title, required this.value});
  final String title;
  final String value;
}