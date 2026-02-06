import 'package:flutter/material.dart';
import '../orders/orders_page.dart';
import '../profile/presentation/screens/chat_list_screen.dart';
import '../profile/presentation/screens/supplier_category_page.dart';
import '../profile/presentation/screens/supplier_profile_screen.dart';
import '../profile/presentation/screens/supplier_payout_page.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../supplier/inventory/ui/add_product_page.dart';

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});
  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  late final List<Widget> _pages = [
    const SupplierDashboardHome(),
    const SupplierCategoryPage(),
    const SizedBox(), // Placeholder for center "Add" button which navigates instead of switching tabs
    const OrdersPage(),
    const SupplierProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Removed FloatingActionButton as requested
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF4CA6A8),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex == 2
              ? 0
              : _selectedIndex, // Prevent selecting "Add Product" visually if needed, but here we treat it as a tab
          onTap: (index) {
            if (index == 2) {
              // Center Tab - Add Product
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              );
            } else {
              _onItemTapped(index);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: "Category",
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CA6A8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: "Order",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

class SupplierDashboardHome extends StatelessWidget {
  const SupplierDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildTopBar(context),
          const SizedBox(height: 20),
          _buildPromoBanner(context),
          const SizedBox(height: 30),
          _buildSectionHeader("Categories"),
          const SizedBox(height: 15),
          _buildCategoryList(context),
          const SizedBox(height: 30),
          _buildSectionHeader("Performance Stats"),
          const SizedBox(height: 15),
          _buildPerformanceGrid(context),
          const SizedBox(height: 100), // ✅ CHANGED: Space for FAB
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.grid_view_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        const SizedBox(width: 15),

        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: "Search analytics...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),

        const SizedBox(width: 15),

        // Theme Toggle (Replaced Cart)
        GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF63B4B7), Color(0xFF4CA6A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Supplier Growth",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Monthly payout is ready",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4CA6A8),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text("View Report"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const Text(
          "See All",
          style: TextStyle(
            color: Color(0xFF4CA6A8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final List<Map<String, dynamic>> cats = [
      {"icon": Icons.inventory_2, "label": "Orders"},
      {"icon": Icons.analytics, "label": "Sales"},
      {"icon": Icons.people, "label": "Clients"},
      {"icon": Icons.account_balance_wallet, "label": "Payouts"},
    ];

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 25),
        itemBuilder: (context, index) {
          final label = cats[index]['label'];

          return InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              //  NAVIGATION LOGIC
              if (label == "Orders") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                );
              } else if (label == "Clients") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                );
              } else if (label == "Payouts") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupplierPayoutPage()),
                );
              } else if (label == "Sales") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sales page coming soon")),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cats[index]['icon'],
                    color: const Color(0xFF4CA6A8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.80,
      children: [
        _statItem(context, "Revenue", "₹ 4.5L", "Supplements", "+12%"),
        _statItem(context, "Pending", "14 Units", "Medicine", "Alert"),
      ],
    );
  }

  Widget _statItem(
    BuildContext context,
    String title,
    String value,
    String sub,
    String badge,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.bar_chart, color: Colors.grey, size: 40),
          ),
          const SizedBox(height: 10),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF4CA6A8),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CA6A8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4CA6A8),
                    fontWeight: FontWeight.bold,
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
