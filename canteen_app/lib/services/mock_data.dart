import '../models/menu_item.dart';

/// Static UI helpers for menu categories. Menu content now lives in Supabase.
class MockData {
  static String categoryIcon(FoodCategory category) {
    switch (category) {
      case FoodCategory.breakfast:
        return '🌅';
      case FoodCategory.lunch:
        return '🍽️';
      case FoodCategory.snacks:
        return '🍿';
      case FoodCategory.drinks:
        return '🥤';
    }
  }

  static String categoryLabel(FoodCategory category) {
    switch (category) {
      case FoodCategory.breakfast:
        return 'Breakfast';
      case FoodCategory.lunch:
        return 'Lunch';
      case FoodCategory.snacks:
        return 'Snacks';
      case FoodCategory.drinks:
        return 'Drinks';
    }
  }
}