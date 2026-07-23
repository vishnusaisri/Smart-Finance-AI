import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/budget.dart';
import '../services/budget_service.dart';

final budgetProvider = StreamNotifierProvider<BudgetController, List<Budget>>(() {
  return BudgetController();
});

class BudgetController extends StreamNotifier<List<Budget>> {
  late BudgetService _service;

  @override
  Stream<List<Budget>> build() {
    _service = ref.watch(budgetServiceProvider);
    return _service.watchBudgets();
  }

  Future<void> saveBudget(Budget budget) async {
    try {
      await _service.saveBudget(budget);
      // Stream will automatically update
    } catch (e, stack) {
      // Error will be reflected in stream
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _service.deleteBudget(id);
      // Stream will automatically update
    } catch (e, stack) {
      // Error will be reflected in stream
    }
  }
}
