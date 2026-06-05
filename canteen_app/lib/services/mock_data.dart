import '../models/menu_item.dart';
import '../models/user.dart';

class MockData {
  static final List<MenuItem> menuItems = [
    MenuItem(
      id: 'item_1',
      name: 'Masala Dosa',
      description: 'Crispy rice crepe filled with spiced potato filling, served with coconut chutney and sambar.',
      price: 45.0,
      category: FoodCategory.breakfast,
      imageUrl: '🍛',
      preparationTimeMinutes: 12,
    ),
    MenuItem(
      id: 'item_2',
      name: 'Idli Vada Combo',
      description: '2 soft idlis and 2 crispy vadas with sambar and chutney.',
      price: 35.0,
      category: FoodCategory.breakfast,
      imageUrl: '🫓',
      preparationTimeMinutes: 8,
    ),
    MenuItem(
      id: 'item_3',
      name: 'Poori Bhaji',
      description: 'Fluffy deep-fried pooris with spicy potato bhaji.',
      price: 40.0,
      category: FoodCategory.breakfast,
      imageUrl: '🫓',
      preparationTimeMinutes: 10,
    ),
    MenuItem(
      id: 'item_4',
      name: 'Veg Biryani',
      description: 'Fragrant basmati rice cooked with mixed vegetables and aromatic spices, served with raita.',
      price: 120.0,
      category: FoodCategory.lunch,
      imageUrl: '🍚',
      preparationTimeMinutes: 20,
    ),
    MenuItem(
      id: 'item_5',
      name: 'Chicken Biryani',
      description: 'Tender chicken pieces layered with basmati rice and biryani masala, served with salan.',
      price: 150.0,
      category: FoodCategory.lunch,
      imageUrl: '🍗',
      preparationTimeMinutes: 25,
    ),
    MenuItem(
      id: 'item_6',
      name: 'North Indian Thali',
      description: 'Complete meal with dal, paneer, roti, rice, salad, and dessert.',
      price: 160.0,
      category: FoodCategory.lunch,
      imageUrl: '🍱',
      preparationTimeMinutes: 20,
    ),
    MenuItem(
      id: 'item_7',
      name: 'French Fries',
      description: 'Crispy golden french fries with peri-peri seasoning.',
      price: 50.0,
      category: FoodCategory.snacks,
      imageUrl: '🍟',
      preparationTimeMinutes: 7,
    ),
    MenuItem(
      id: 'item_8',
      name: 'Veg Spring Rolls',
      description: 'Crispy rolls stuffed with seasoned mixed vegetables, served with sweet chili sauce.',
      price: 55.0,
      category: FoodCategory.snacks,
      imageUrl: '🥟',
      preparationTimeMinutes: 10,
    ),
    MenuItem(
      id: 'item_9',
      name: 'Samosa (2 pcs)',
      description: 'Crispy fried pastries filled with spiced potato and peas.',
      price: 25.0,
      category: FoodCategory.snacks,
      imageUrl: '🥟',
      preparationTimeMinutes: 5,
    ),
    MenuItem(
      id: 'item_10',
      name: 'Masala Chai',
      description: 'Traditional Indian spiced tea brewed with fresh ginger and cardamom.',
      price: 15.0,
      category: FoodCategory.drinks,
      imageUrl: '☕',
      preparationTimeMinutes: 3,
    ),
    MenuItem(
      id: 'item_11',
      name: 'Mango Lassi',
      description: 'Creamy yogurt drink blended with ripe mango pulp.',
      price: 40.0,
      category: FoodCategory.drinks,
      imageUrl: '🥤',
      preparationTimeMinutes: 4,
    ),
    MenuItem(
      id: 'item_12',
      name: 'Fresh Lime Soda',
      description: 'Refreshing lime soda with a hint of mint and black salt.',
      price: 20.0,
      category: FoodCategory.drinks,
      imageUrl: '🍋',
      preparationTimeMinutes: 3,
    ),
    MenuItem(
      id: 'item_13',
      name: 'Cold Coffee',
      description: 'Chilled blended coffee with vanilla ice cream.',
      price: 55.0,
      category: FoodCategory.drinks,
      imageUrl: '☕',
      preparationTimeMinutes: 5,
    ),
    MenuItem(
      id: 'item_14',
      name: 'Paneer Wrap',
      description: 'Whole wheat wrap filled with spiced paneer, onions, and bell peppers.',
      price: 70.0,
      category: FoodCategory.snacks,
      imageUrl: '🌯',
      preparationTimeMinutes: 10,
    ),
    MenuItem(
      id: 'item_15',
      name: 'Egg Fried Rice',
      description: 'Wok-fried rice with egg, vegetables, and soy sauce.',
      price: 85.0,
      category: FoodCategory.lunch,
      imageUrl: '🍚',
      preparationTimeMinutes: 12,
    ),
  ];

  static final List<AppUser> dummyUsers = [
    AppUser(
      id: 'staff_1',
      name: 'Canteen Manager',
      email: 'manager@college.edu',
      rollNumber: 'STAFF001',
      role: UserRole.staff,
    ),
    AppUser(
      id: 'student_1',
      name: 'Rahul Sharma',
      email: 'rahul.sharma@college.edu',
      rollNumber: 'CS21001',
      role: UserRole.student,
    ),
    AppUser(
      id: 'student_2',
      name: 'Priya Patel',
      email: 'priya.patel@college.edu',
      rollNumber: 'CS21002',
      role: UserRole.student,
    ),
  ];

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
