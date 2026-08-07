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

  // Helper to parse budgets list from dynamic snapshot value
  List<Budget> _parseBudgets(dynamic val) {
    if (val == null) return [];
    final Iterable items;
    if (val is Map) {
      items = val.values;
    } else if (val is List) {
      items = val.where((e) => e != null);
    } else {
      return [];
    }

    final list = <Budget>[];
    for (final item in items) {
      if (item is Map) {
        try {
          final convertedMap = _convertToMap(item) ?? Map<String, dynamic>.from(item);
          list.add(Budget.fromMap(convertedMap));
        } catch (e) {
          debugPrint('Error parsing budget item: $e');
        }
      }
    }
    return list;
  }

  Future<List<Budget>> getBudgets() async {
    if (_userId.isEmpty) return [];
    
    try {
      final snapshot = await _database.ref('users/$_userId/budgets').get();
      if (snapshot.exists && snapshot.value != null) {
        return _parseBudgets(snapshot.value);
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

      final Iterable items;
      if (snapshot.value is Map) {
        items = (snapshot.value as Map).values;
      } else if (snapshot.value is List) {
        items = (snapshot.value as List).where((e) => e != null);
      } else {
        return 0;
      }

      final expenses = <Expense>[];
      for (final item in items) {
        if (item is Map) {
          try {
            expenses.add(Expense.fromMap(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }

      final now = DateTime.now();
      
      // Filter expenses by category and date range (current month)
      final categoryExpenses = expenses.where((expense) {
        final expenseDate = expense.date;
        final isCurrentMonth = expenseDate.year == now.year && expenseDate.month == now.month;
        return expense.category.toLowerCase() == category.toLowerCase() && isCurrentMonth;
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
    
    return _database.ref('users/$_userId/budgets').onValue.asyncMap((budgetEvent) async {
      final val = budgetEvent.snapshot.value;
      if (val == null) return <Budget>[];
      
      final budgets = _parseBudgets(val);
      
      // Calculate spent amounts from expenses for each budget
      final updatedBudgets = await Future.wait(budgets.map((budget) async {
        final spent = await _calculateSpentForCategory(budget.category, budget.startDate);
        return budget.copyWith(spent: spent, updatedAt: DateTime.now());
      }));
      
      return updatedBudgets;
    });
  }
}
