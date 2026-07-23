import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/budget.dart';
import '../../budget/services/budget_service.dart';

// Expense Service - All operations go to Firebase Realtime Database
class ExpenseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BudgetService _budgetService = BudgetService();

  String get _userId => _auth.currentUser?.uid ?? '';
  
  DatabaseReference get _expensesRef {
    return _database.child('users').child(_userId).child('expenses');
  }

  DatabaseReference get _budgetsRef {
    return _database.child('users').child(_userId).child('budgets');
  }

  // Get all expenses from Realtime Database
  Future<List<Expense>> getAllExpenses() async {
    if (_userId.isEmpty) return [];
    
    try {
      final snapshot = await _expensesRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.values
            .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      }
      return [];
    } catch (e) {
      debugPrint('Error getting expenses: $e');
      return [];
    }
  }

  // Get expense by ID
  Future<Expense?> getExpenseById(String id) async {
    if (_userId.isEmpty) return null;
    
    try {
      final snapshot = await _expensesRef.child(id).get();
      if (snapshot.exists && snapshot.value != null) {
        return Expense.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      debugPrint('Error getting expense: $e');
      return null;
    }
  }

  // Add new expense and update corresponding budget
  Future<void> addExpense(Expense expense) async {
    if (_userId.isEmpty) return;
    await _expensesRef.child(expense.id).set(expense.toMap());
    debugPrint('Expense added: ${expense.id}');
    
    // Update budget spent amount
    await _updateBudgetForExpense(expense);
  }

  // Update expense and update corresponding budget
  Future<void> updateExpense(Expense expense, {Expense? oldExpense}) async {
    if (_userId.isEmpty) return;
    await _expensesRef.child(expense.id).update(expense.toMap());
    debugPrint('Expense updated: ${expense.id}');
    
    // Update budget spent amounts for both old and new expense
    if (oldExpense != null) {
      await _updateBudgetForExpense(oldExpense, isRemoval: true);
    }
    await _updateBudgetForExpense(expense);
  }

  // Delete expense and update corresponding budget
  Future<void> deleteExpense(String id, {Expense? expense}) async {
    if (_userId.isEmpty) return;
    await _expensesRef.child(id).remove();
    debugPrint('Expense deleted: $id');
    
    // Update budget spent amount
    if (expense != null) {
      await _updateBudgetForExpense(expense, isRemoval: true);
    }
  }

  // Update budget spent amount based on expense
  Future<void> _updateBudgetForExpense(Expense expense, {bool isRemoval = false}) async {
    try {
      final budgets = await _budgetService.getBudgets();
      final matchingBudget = budgets.firstWhere(
        (b) => b.category.toLowerCase() == expense.category.toLowerCase(),
        orElse: () => budgets.firstWhere(
          (b) => _categoriesMatch(b.category, expense.category),
          orElse: () => Budget(
            id: '',
            userId: _userId,
            category: expense.category,
            amount: 0,
            startDate: DateTime.now(),
          ),
        ),
      );
      
      if (matchingBudget.id.isNotEmpty) {
        // Calculate total spent for this category
        final allExpenses = await getAllExpenses();
        final categoryExpenses = allExpenses.where((e) => 
          _categoriesMatch(e.category, matchingBudget.category)
        ).toList();
        
        final totalSpent = categoryExpenses.fold<double>(0, (sum, e) => sum + e.amount);
        
        // Update budget with new spent amount
        final updatedBudget = matchingBudget.copyWith(
          spent: totalSpent,
          updatedAt: DateTime.now(),
        );
        
        await _budgetService.saveBudget(updatedBudget);
        debugPrint('Budget updated: ${matchingBudget.category} spent: $totalSpent');
      }
    } catch (e) {
      debugPrint('Error updating budget for expense: $e');
    }
  }

  // Check if categories match (case-insensitive, handles variations)
  bool _categoriesMatch(String budgetCategory, String expenseCategory) {
    return budgetCategory.toLowerCase().trim() == expenseCategory.toLowerCase().trim();
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final all = await getAllExpenses();
    return all.where((e) => e.category == category).toList();
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final all = await getAllExpenses();
    return all.where((e) => 
      e.date.isAfter(start) && e.date.isBefore(end)
    ).toList();
  }

  // Real-time stream of expenses
  Stream<List<Expense>> watchExpenses() {
    if (_userId.isEmpty) return Stream.value([]);
    
    return _expensesRef.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <Expense>[];
      if (val is Map) {
        final list = (val as Map<dynamic, dynamic>).values
            .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      }
      return <Expense>[];
    });
  }
}
