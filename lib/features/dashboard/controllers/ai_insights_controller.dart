import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/ai_insight.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../profile/providers/profile_providers.dart';

// AI Insights Provider - generates real insights based on actual expense data
final aiInsightsProvider = FutureProvider<List<AIInsight>>((ref) async {
  final expensesAsync = ref.watch(expensesProvider);
  final userProfile = ref.watch(userProfileProvider);
  final symbol = userProfile.getCurrencySymbol();

  return expensesAsync.when(
    loading: () => [],
    error: (error, stack) => [],
    data: (expenses) async {
      final insights = <AIInsight>[];
      final userId = 'current_user';
      
      if (expenses.isEmpty) {
        insights.add(AIInsight(
          id: 'no-data',
          userId: userId,
          title: 'Start Tracking!',
          description: 'Add your first expense to get personalized financial insights.',
          type: InsightType.info,
          timestamp: DateTime.now(),
        ));
        return insights;
      }

      // Calculate real metrics
      final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
      final avgPerExpense = total / expenses.length;
      
      // Category analysis
      final byCategory = <String, double>{};
      for (final expense in expenses) {
        byCategory[expense.category] = (byCategory[expense.category] ?? 0) + expense.amount;
      }
      
      // Find highest spending category
      String? topCategory;
      double topAmount = 0;
      byCategory.forEach((cat, amount) {
        if (amount > topAmount) {
          topAmount = amount;
          topCategory = cat;
        }
      });

      // Last 7 days spending
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final weekExpenses = expenses.where((e) => e.date.isAfter(weekAgo)).toList();
      final weekTotal = weekExpenses.fold<double>(0, (sum, e) => sum + e.amount);

      // Last 30 days spending
      final monthAgo = now.subtract(const Duration(days: 30));
      final monthExpenses = expenses.where((e) => e.date.isAfter(monthAgo)).toList();
      final monthTotal = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);

      // Generate insights based on real data
      
      // 1. Weekly spending insight
      if (weekTotal > 0) {
        final dailyAvg = weekTotal / 7;
        insights.add(AIInsight(
          id: 'weekly-spend',
          userId: userId,
          title: 'Weekly Spending: $symbol${weekTotal.toStringAsFixed(0)}',
          description: 'You\'re spending an average of $symbol${dailyAvg.toStringAsFixed(0)}/day this week across ${weekExpenses.length} transactions.',
          type: weekTotal > monthTotal / 4 ? InsightType.warning : InsightType.success,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ));
      }

      // 2. Top category insight
      if (topCategory != null) {
        final percentage = (topAmount / total * 100).toStringAsFixed(0);
        insights.add(AIInsight(
          id: 'top-category',
          userId: userId,
          title: 'Top Category: $topCategory',
          description: '$topCategory accounts for $percentage% of your total spending ($symbol${topAmount.toStringAsFixed(0)}).',
          type: double.parse(percentage) > 50 ? InsightType.warning : InsightType.info,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ));
      }

      // 3. Monthly total insight
      if (monthTotal > 0) {
        insights.add(AIInsight(
          id: 'monthly-total',
          userId: userId,
          title: 'Monthly Total: $symbol${monthTotal.toStringAsFixed(0)}',
          description: 'You\'ve logged ${monthExpenses.length} expenses this month with an average of $symbol${(monthTotal / monthExpenses.length).toStringAsFixed(0)} each.',
          type: InsightType.info,
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ));
      }

      // 4. Large expense alert
      final largeExpenses = expenses.where((e) => e.amount > avgPerExpense * 2).toList();
      if (largeExpenses.isNotEmpty) {
        insights.add(AIInsight(
          id: 'large-expenses',
          userId: userId,
          title: '${largeExpenses.length} Large Transactions',
          description: 'You have ${largeExpenses.length} expenses above $symbol${(avgPerExpense * 2).toStringAsFixed(0)}. Review them to find potential savings.',
          type: InsightType.warning,
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        ));
      }

      // 5. Positive insight if spending is controlled
      if (byCategory.length >= 3 && total > 0) {
        final isBalanced = byCategory.values.every((v) => v / total < 0.6);
        if (isBalanced) {
          insights.add(AIInsight(
            id: 'balanced',
            userId: userId,
            title: 'Well Balanced!',
            description: 'Your spending is well distributed across ${byCategory.length} categories. Great financial discipline!',
            type: InsightType.success,
            timestamp: DateTime.now(),
          ));
        }
      }

      return insights;
    },
  );
});
