import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../services/mock_data.dart';
import '../../utils/constants.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();

    return RefreshIndicator(
      onRefresh: () => menuProvider.loadMenu(),
      color: AppColors.primary,
      child: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Category filter chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: FoodCategory.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = FoodCategory.values[index];
                      final isSelected = menuProvider.selectedCategory == category;
                      return FilterChip(
                        label: Text(MockData.categoryLabel(category)),
                        selected: isSelected,
                        onSelected: (_) => menuProvider.setCategory(category),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Menu items in category
                ...menuProvider.filteredItems.map((item) => _MenuItemManagementCard(
                      item: item,
                      onToggleAvailability: () => menuProvider.toggleAvailability(item.id),
                    )),
              ],
            ),
    );
  }
}

class _MenuItemManagementCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onToggleAvailability;

  const _MenuItemManagementCard({
    required this.item,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item emoji
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.imageUrl, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                      Text('₹${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${item.preparationTimeMinutes} min prep',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Availability toggle
            Switch(
              value: item.isAvailable,
              onChanged: (_) => onToggleAvailability(),
              activeTrackColor: AppColors.success.withValues(alpha: 0.4),
              activeThumbColor: AppColors.success,
              inactiveThumbColor: AppColors.error,
              inactiveTrackColor: AppColors.error.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
