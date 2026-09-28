import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _openAddItemSheet() async {
    final menuProvider = context.read<MenuProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final item = await showModalBottomSheet<MenuItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddItemSheet(),
    );

    if (item == null) return;

    await menuProvider.addMenuItem(item);
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text('Added "${item.name}" to the menu'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                // Add item button
                ElevatedButton.icon(
                  onPressed: _openAddItemSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add menu item',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (menuProvider.menuItems.isEmpty)
                  _EmptyMenuState(onAddPressed: _openAddItemSheet)
                else ...[
                  // Category filter chips
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: FoodCategory.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = FoodCategory.values[index];
                        final isSelected =
                            menuProvider.selectedCategory == category;
                        return FilterChip(
                          label: Text(MockData.categoryLabel(category)),
                          selected: isSelected,
                          onSelected: (_) => menuProvider.setCategory(category),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
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
                  ...menuProvider.filteredItems.map((item) =>
                      _MenuItemManagementCard(
                        item: item,
                        onToggleAvailability: () =>
                            menuProvider.toggleAvailability(item.id),
                      )),
                ],
              ],
            ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyMenuState({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'Menu is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first item to get started.\nStudents will see it instantly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('Add first item'),
          ),
        ],
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _emojiController = TextEditingController(text: '🍽️');
  final _prepController = TextEditingController(text: '10');
  FoodCategory _category = FoodCategory.breakfast;
  bool _isAvailable = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _emojiController.dispose();
    _prepController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final item = await Future.value(MenuItem(
      id: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _category,
      imageUrl: _emojiController.text.trim().isEmpty
          ? '🍽️'
          : _emojiController.text.trim(),
      isAvailable: _isAvailable,
      preparationTimeMinutes: int.parse(_prepController.text.trim()),
    ));

    if (mounted) Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Add menu item',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = double.tryParse(v?.trim() ?? '');
                        if (value == null || value <= 0) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _prepController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Prep time (min)',
                        suffixText: 'min',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = int.tryParse(v?.trim() ?? '');
                        if (value == null || value <= 0) {
                          return 'Enter minutes';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<FoodCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: FoodCategory.values
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(MockData.categoryLabel(c)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _category = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      controller: _emojiController,
                      maxLength: 4,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Emoji',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _isAvailable,
                onChanged: (value) => setState(() => _isAvailable = value),
                title: const Text('Available to students'),
                contentPadding: EdgeInsets.zero,
                activeTrackColor: AppColors.success.withValues(alpha: 0.4),
                activeThumbColor: AppColors.success,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: const Text('Add to menu',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
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