import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/budget.dart';
import '../../../core/models/expense.dart';

final budgetServiceProvider = Provider<BudgetService>((ref) {
  return BudgetService();
});

class BudgetService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  DatabaseReference get _expensesRef {
    return _database.ref('users').child(_userId).child('expenses');
  }

  Map<String, dynamic>? _convertToMap(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data.map((key, value) {
        final keyString = key.toString();
        if (value is Map) {
          return MapEntry(keyString, _convertToMap(value));
        } else if (value is List) {
          return MapEntry(keyString, value.map((item) {
            if (item is Map) {
              return _convertToMap(item);
            }
            return item;
          }).toList());
        }
        return MapEntry(keyString, value);
      });
    }
    return null;
  }

  Future<List<Budget>> getBudgets() async {
    if (_userId.isEmpty) return [];
    
    try {
      final snapshot = await _database.ref('users/$_userId/budgets').get();
      if (snapshot.exists && snapshot.value != null) {
        final converted = _convertToMap(snapshot.value) ?? {};
        return converted.values.map((item) {
          if (item is Map<String, dynamic>) {
            return Budget.fromMap(item);
          }
          return Budget.fromMap(Map<String, dynamic>.from(item as Map));
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting budgets: $e');
      return [];
    }
  }

  Future<void> saveBudget(Budget budget) async {
    if (_userId.isEmpty) {
      debugPrint('Cannot save budget: No user logged in');
      return;
    }
    // Ensure budget belongs to current user
    final budgetToSave = budget.userId.isEmpty 
        ? budget.copyWith(userId: _userId)
        : budget;
    
    final budgetData = budgetToSave.toMap();
    debugPrint('Saving budget data: $budgetData');
    
    await _database.ref('users/$_userId/budgets/${budgetToSave.id}').set(budgetData);
    debugPrint('Budget saved: ${budgetToSave.id}');
  }
  
  Future<void> deleteBudget(String id) async {
    if (_userId.isEmpty) return;
    await _database.ref('users/$_userId/budgets/$id').remove();
    debugPrint('Budget deleted: $id');
  }

  // Calculate spent amount for a budget category from expenses
  Future<double> _calculateSpentForCategory(String category, DateTime startDate) async {
    try {
      // Fetch expenses directly from Firebase
      final snapshot = await _expensesRef.get();
      if (!snapshot.exists || snapshot.value == null) {
        return 0;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final expenses = data.values
          .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      final now = DateTime.now();
      
      // Filter expenses by category and date range (current month)
      final categoryExpenses = expenses.where((expense) {
        final expenseDate = expense.date;
        final isCurrentMonth = expenseDate.year == now.year && expenseDate.month == now.month;
        return expense.category == category && isCurrentMonth;
      }).toList();
      
      return categoryExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      debugPrint('Error calculating spent for category $category: $e');
      return 0;
    }
  }

  // Real-time stream for budget updates with expense calculations
  Stream<List<Budget>> watchBudgets() {
    if (_userId.isEmpty) {
      debugPrint('Cannot watch budgets: No user logged in');
      return Stream.value([]);
    }
    
    debugPrint('Watching budgets for user: $_userId');
    
    // Combine budget stream with expense stream to calculate spent amounts
    return _database.ref('users/$_userId/budgets').onValue.asyncMap((budgetEvent) async {
      final val = budgetEvent.snapshot.value;
      debugPrint('Budgets snapshot value: $val');
      
      if (val == null) return <Budget>[];
      if (val is Map) {
        final converted = _convertToMap(val) ?? {};
        debugPrint('Converted budgets map: $converted');
        
        final budgets = converted.values.map((item) {
          if (item is Map<String, dynamic>) {
            return Budget.fromMap(item);
          }
          return Budget.fromMap(Map<String, dynamic>.from(item as Map));
        }).toList();
        
        debugPrint('Parsed budgets count: ${budgets.length}');
        
        // Calculate spent amounts from expenses for each budget
        final updatedBudgets = await Future.wait(budgets.map((budget) async {
          final spent = await _calculateSpentForCategory(budget.category, budget.startDate);
          return budget.copyWith(spent: spent, updatedAt: DateTime.now());
        }));
        
        return updatedBudgets;
      }
      return <Budget>[];
    });
  }
}
