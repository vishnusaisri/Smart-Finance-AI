import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';
import '../services/expense_service.dart';

// Debounced Search Provider
final searchQueryProvider = Provider<String>((ref) => '');

final debouncedSearchQueryProvider = Provider<String>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  return searchQuery;
});

// Expense Controller Provider
final expenseControllerProvider = AsyncNotifierProvider<ExpenseController, List<Expense>>(() {
  return ExpenseController();
});

// Expense Service Provider
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

// All Expenses Provider - Uses real-time Realtime Database stream
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final service = ref.watch(expenseServiceProvider);
  return service.watchExpenses();
});

// Expenses List Provider (for backward compatibility)
final expensesListProvider = Provider<List<Expense>>((ref) {
  final expensesAsync = ref.watch(expensesProvider);
  return expensesAsync.when(
    data: (expenses) => expenses,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Filtered Expenses Provider
final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final expensesAsync = ref.watch(expensesProvider);
  final filter = ref.watch(expenseFilterProvider);
  final searchQuery = ref.watch(debouncedSearchQueryProvider).toLowerCase();
  
  return expensesAsync.when(
    data: (expenses) {
      var filtered = expenses;
      
      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((e) =>
          e.description.toLowerCase().contains(searchQuery) ||
          e.category.toLowerCase().contains(searchQuery)
        ).toList();
      }
      
      // Apply category filter
      if (filter.category != null) {
        filtered = filtered.where((e) => e.category == filter.category).toList();
      }
      
      // Apply date range filters
      if (filter.startDate != null) {
        filtered = filtered.where((e) => e.date.isAfter(filter.startDate!)).toList();
      }
      
      if (filter.endDate != null) {
        filtered = filtered.where((e) => e.date.isBefore(filter.endDate!)).toList();
      }
      
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Expense Filter Provider
class ExpenseFilterController extends Notifier<ExpenseFilter> {
  @override
  ExpenseFilter build() => ExpenseFilter();
  
  void updateFilter(ExpenseFilter filter) {
    state = filter;
  }
  
  void reset() {
    state = ExpenseFilter();
  }
}

final expenseFilterControllerProvider = NotifierProvider<ExpenseFilterController, ExpenseFilter>(() {
  return ExpenseFilterController();
});

final expenseFilterProvider = Provider<ExpenseFilter>((ref) {
  return ref.watch(expenseFilterControllerProvider);
});

// Expense Stats Provider - Real-time calculations from actual data
final expenseStatsProvider = Provider<ExpenseStats>((ref) {
  final expensesAsync = ref.watch(expensesProvider);
  
  return expensesAsync.when(
    data: (expenses) {
      if (expenses.isEmpty) {
        return ExpenseStats(total: 0, average: 0, max: 0, count: 0, byCategory: {});
      }
      
      final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
      final average = total / expenses.length;
      final max = expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
      
      final byCategory = <String, double>{};
      for (final expense in expenses) {
        byCategory[expense.category] = 
            (byCategory[expense.category] ?? 0) + expense.amount;
      }
      
      // Calculate monthly totals for trend
      final monthlyTotals = <String, double>{};
      for (final expense in expenses) {
        final key = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + expense.amount;
      }
      
      return ExpenseStats(
        total: total,
        average: average,
        max: max,
        count: expenses.length,
        byCategory: byCategory,
        monthlyTotals: monthlyTotals,
      );
    },
    loading: () => ExpenseStats(total: 0, average: 0, max: 0, count: 0, byCategory: {}),
    error: (_, __) => ExpenseStats(total: 0, average: 0, max: 0, count: 0, byCategory: {}),
  );
});

// Expense Filter Model
class ExpenseFilter {
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  ExpenseFilter({
    this.category,
    this.startDate,
    this.endDate,
  });

  ExpenseFilter copyWith({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExpenseFilter(
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// Expense Stats Model
class ExpenseStats {
  final double total;
  final double average;
  final double max;
  final int count;
  final Map<String, double> byCategory;
  final Map<String, double> monthlyTotals;

  ExpenseStats({
    required this.total,
    required this.average,
    required this.max,
    required this.count,
    required this.byCategory,
    this.monthlyTotals = const {},
  });
}

// Expense Controller
class ExpenseController extends AsyncNotifier<List<Expense>> {
  late ExpenseService _service;

  @override
  FutureOr<List<Expense>> build() async {
    _service = ref.watch(expenseServiceProvider);
    return await _service.getAllExpenses();
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _service.getAllExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addExpense(Expense expense) async {
    final currentExpenses = state.value ?? [];
    state = AsyncValue.data([...currentExpenses, expense]);
    
    try {
      await _service.addExpense(expense);
    } catch (e) {
      state = AsyncValue.data(currentExpenses);
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    final currentExpenses = state.value ?? [];
    final oldExpense = currentExpenses.firstWhere((e) => e.id == expense.id);
    state = AsyncValue.data(
      currentExpenses.map((e) => e.id == expense.id ? expense : e).toList(),
    );
    
    try {
      await _service.updateExpense(expense, oldExpense: oldExpense);
    } catch (e) {
      state = AsyncValue.data(currentExpenses);
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    final currentExpenses = state.value ?? [];
    final expenseToDelete = currentExpenses.firstWhere((e) => e.id == id);
    state = AsyncValue.data(currentExpenses.where((e) => e.id != id).toList());
    
    try {
      await _service.deleteExpense(id, expense: expenseToDelete);
    } catch (e) {
      state = AsyncValue.data(currentExpenses);
      rethrow;
    }
  }

  Future<Expense?> getExpenseById(String id) async {
    return await _service.getExpenseById(id);
  }
}
