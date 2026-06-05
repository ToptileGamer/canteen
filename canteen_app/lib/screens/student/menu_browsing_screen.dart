import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import '../../services/mock_data.dart';
import '../../widgets/menu_item_card.dart';

class MenuBrowsingScreen extends StatefulWidget {
  const MenuBrowsingScreen({super.key});

  @override
  State<MenuBrowsingScreen> createState() => _MenuBrowsingScreenState();
}

class _MenuBrowsingScreenState extends State<MenuBrowsingScreen> {
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
      child: CustomScrollView(
        slivers: [
          // Category chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: FoodCategory.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = FoodCategory.values[index];
                    final isSelected = menuProvider.selectedCategory == category;
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(MockData.categoryIcon(category)),
                          const SizedBox(width: 6),
                          Text(MockData.categoryLabel(category)),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) => menuProvider.setCategory(category),
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Menu items grid
          menuProvider.isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final items = menuProvider.filteredItems;
                        if (index >= items.length) return null;
                        final item = items[index];
                        return MenuItemCard(
                          item: item,
                          onAddToCart: () {
                            context.read<CartProvider>().addItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} added to cart'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      },
                      childCount: menuProvider.filteredItems.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
