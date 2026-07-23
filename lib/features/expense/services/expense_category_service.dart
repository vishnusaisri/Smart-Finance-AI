import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

// Expense Category Service
class ExpenseCategoryService {
  static final List<ExpenseCategory> _categories = [
    ExpenseCategory(
      id: 'food',
      name: AppStrings.foodAndDining,
      icon: Icons.restaurant,
      color: AppColors.primary,
      keywords: ['restaurant', 'cafe', 'food', 'lunch', 'dinner', 'coffee', 'grocery'],
    ),
    ExpenseCategory(
      id: 'transport',
      name: AppStrings.transportation,
      icon: Icons.directions_car,
      color: AppColors.secondary,
      keywords: ['uber', 'taxi', 'gas', 'parking', 'metro', 'bus', 'transport'],
    ),
    ExpenseCategory(
      id: 'shopping',
      name: AppStrings.shopping,
      icon: Icons.shopping_bag,
      color: AppColors.accent,
      keywords: ['shopping', 'store', 'amazon', 'clothing', 'electronics'],
    ),
    ExpenseCategory(
      id: 'entertainment',
      name: AppStrings.entertainment,
      icon: Icons.movie,
      color: AppColors.success,
      keywords: ['movie', 'concert', 'gaming', 'sports', 'entertainment'],
    ),
    ExpenseCategory(
      id: 'bills',
      name: AppStrings.billsAndUtilities,
      icon: Icons.receipt,
      color: AppColors.warning,
      keywords: ['electricity', 'internet', 'phone', 'water', 'rent', 'bill', 'utility'],
    ),
    ExpenseCategory(
      id: 'healthcare',
      name: AppStrings.healthcare,
      icon: Icons.local_hospital,
      color: AppColors.danger,
      keywords: ['pharmacy', 'doctor', 'hospital', 'gym', 'health', 'medical'],
    ),
    ExpenseCategory(
      id: 'education',
      name: AppStrings.education,
      icon: Icons.school,
      color: const Color(0xFF8B5CF6),
      keywords: ['course', 'book', 'workshop', 'tutorial', 'education', 'school'],
    ),
    ExpenseCategory(
      id: 'travel',
      name: AppStrings.travel,
      icon: Icons.flight,
      color: const Color(0xFFEC4899),
      keywords: ['flight', 'hotel', 'travel', 'vacation', 'trip'],
    ),
    ExpenseCategory(
      id: 'subscriptions',
      name: AppStrings.subscriptions,
      icon: Icons.repeat,
      color: const Color(0xFF14B8A6),
      keywords: ['subscription', 'netflix', 'spotify', 'monthly', 'recurring'],
    ),
    ExpenseCategory(
      id: 'investments',
      name: AppStrings.investments,
      icon: Icons.trending_up,
      color: const Color(0xFF84CC16),
      keywords: ['investment', 'stock', 'crypto', 'mutual fund'],
    ),
    ExpenseCategory(
      id: 'others',
      name: AppStrings.others,
      icon: Icons.category,
      color: AppColors.textSecondary,
      keywords: [],
    ),
  ];

  // Get all categories
  static List<ExpenseCategory> getAllCategories() {
    return _categories;
  }

  // Get category by name
  static ExpenseCategory getCategoryByName(String name) {
    return _categories.firstWhere(
      (c) => c.name == name,
      orElse: () => _categories.last, // Return 'Others' if not found
    );
  }

  // Smart categorization based on description
  static String suggestCategory(String description) {
    final lowerDesc = description.toLowerCase();
    
    for (final category in _categories) {
      for (final keyword in category.keywords) {
        if (lowerDesc.contains(keyword)) {
          return category.name;
        }
      }
    }
    
    return AppStrings.others;
  }

  // Get category icon
  static IconData getCategoryIcon(String categoryName) {
    final category = getCategoryByName(categoryName);
    return category.icon;
  }

  // Get category color
  static Color getCategoryColor(String categoryName) {
    final category = getCategoryByName(categoryName);
    return category.color;
  }
}

// Expense Category Model
class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> keywords;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.keywords = const [],
  });
}
