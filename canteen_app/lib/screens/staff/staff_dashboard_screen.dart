import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import 'order_management_screen.dart';
import 'menu_management_screen.dart';
import 'analytics_screen.dart';
import '../auth/login_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    OrderManagementScreen(),
    MenuManagementScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Staff Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${orderProvider.todayOrderCount} orders today',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () {
              orderProvider.loadActiveOrders();
              orderProvider.loadAnalytics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          // Refresh data when switching tabs
          if (index == 0) orderProvider.loadActiveOrders();
          if (index == 2) orderProvider.loadAnalytics();
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: orderProvider.pendingOrders.isNotEmpty,
              label: Text('${orderProvider.pendingOrders.length}'),
              child: const Icon(Icons.dashboard),
            ),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          const NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
