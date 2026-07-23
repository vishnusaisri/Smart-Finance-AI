import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';

// Expense Service - handles real-time Realtime Database operations
class ExpenseFirestoreService {
  final FirebaseDatabase? _database;
  final FirebaseAuth? _auth;

  ExpenseFirestoreService() 
      : _database = _getDatabase(),
        _auth = _getFirebaseAuth();

  static FirebaseDatabase? _getDatabase() {
    try {
      return FirebaseDatabase.instance;
    } catch (e) {
      return null;
    }
  }

  static FirebaseAuth? _getFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  bool get isAvailable => _auth != null && _database != null;

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

  // Get expenses stream for real-time updates
  Stream<List<Expense>> watchExpenses(String userId) {
    if (!isAvailable) {
      return Stream.value([]);
    }

    return _database!
        .ref('users/$userId/expenses')
        .onValue
        .map((event) {
          final val = event.snapshot.value;
          if (val == null) return <Expense>[];
          if (val is Map) {
            final converted = _convertToMap(val) ?? {};
            final list = converted.values.map((item) {
              if (item is Map<String, dynamic>) {
                return Expense.fromMap(item);
              }
              return Expense.fromMap(Map<String, dynamic>.from(item as Map));
            }).toList();
            // Sort by date descending
            list.sort((a, b) => b.date.compareTo(a.date));
            return list;
          }
          return <Expense>[];
        });
  }

  // Add expense to database
  Future<void> addExpense(String userId, Expense expense) async {
    if (!isAvailable) return;

    try {
      await _database!
          .ref('users/$userId/expenses/${expense.id}')
          .set(expense.toMap());
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  // Update expense in database
  Future<void> updateExpense(String userId, Expense expense) async {
    if (!isAvailable) return;

    try {
      await _database!
          .ref('users/$userId/expenses/${expense.id}')
          .update(expense.toMap());
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  // Delete expense from database
  Future<void> deleteExpense(String userId, String expenseId) async {
    if (!isAvailable) return;

    try {
      await _database!
          .ref('users/$userId/expenses/$expenseId')
          .remove();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  // Get expense by ID
  Future<Expense?> getExpense(String userId, String expenseId) async {
    if (!isAvailable) return null;

    try {
      final snapshot = await _database!
          .ref('users/$userId/expenses/$expenseId')
          .get();
      
      if (snapshot.exists && snapshot.value != null) {
        final converted = _convertToMap(snapshot.value) ?? {};
        return Expense.fromMap(converted);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting expense: $e');
      return null;
    }
  }

  // Batch operations for syncing
  Future<void> syncExpenses(String userId, List<Expense> expenses) async {
    if (!isAvailable) return;

    try {
      final updates = <String, Map<String, dynamic>>{};
      for (final expense in expenses) {
        updates['users/$userId/expenses/${expense.id}'] = expense.toMap();
      }
      await _database!.ref().update(updates);
    } catch (e) {
      debugPrint('Error syncing expenses: $e');
      rethrow;
    }
  }
}

// Provider
final expenseFirestoreServiceProvider = Provider<ExpenseFirestoreService>((ref) {
  return ExpenseFirestoreService();
});

// Real-time expenses provider
final realtimeExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final auth = FirebaseAuth.instance.currentUser;
  if (auth == null) {
    return Stream.value([]);
  }
  return ref.watch(expenseFirestoreServiceProvider).watchExpenses(auth.uid);
});
