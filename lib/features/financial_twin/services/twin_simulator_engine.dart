import '../../../core/models/expense.dart';

class TwinSimulationResult {
  final List<double> currentTrajectory;
  final List<double> optimizedTrajectory;
  final List<String> monthLabels;
  final double currentNetWorth;
  final double optimizedNetWorth;
  final List<String> recommendations;

  TwinSimulationResult({
    required this.currentTrajectory,
    required this.optimizedTrajectory,
    required this.monthLabels,
    required this.currentNetWorth,
    required this.optimizedNetWorth,
    required this.recommendations,
  });
}

class TwinSimulatorEngine {
  /// Simulates financial future comparing current behavior vs optimized behavior over 12 months.
  static TwinSimulationResult simulateFuture({
    required double currentSavings,
    required double monthlyIncome,
    required List<Expense> pastExpenses,
    double savingsRate = 0.2,
  }) {
    if (pastExpenses.isEmpty || monthlyIncome == 0) {
      return TwinSimulationResult(
        currentTrajectory: List.filled(12, currentSavings),
        optimizedTrajectory: List.filled(12, currentSavings),
        monthLabels: _generateMonthLabels(12),
        currentNetWorth: currentSavings,
        optimizedNetWorth: currentSavings,
        recommendations: ['Not enough data to run simulation.'],
      );
    }

    // 1. Calculate Current Behavior Metrics
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentExpenses = pastExpenses.where((e) => e.date.isAfter(thirtyDaysAgo)).toList();
    
    final currentMonthlySpend = recentExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final currentMonthlySavings = monthlyIncome - currentMonthlySpend;
    
    // Identify leaks (Wants & Impulse)
    final wantsCategories = ['Shopping', 'Entertainment', 'Food & Dining', 'Subscriptions'];
    final wantsSpend = recentExpenses
        .where((e) => wantsCategories.contains(e.category) || e.isImpulse)
        .fold<double>(0, (sum, e) => sum + e.amount);

    // 2. Calculate Optimized Behavior Metrics
    // Use the provided savings rate to calculate optimized savings
    final targetSavings = monthlyIncome * savingsRate;
    final optimizedMonthlySavings = targetSavings;

    // 3. Run Simulation (12 months)
    final currentTrajectory = <double>[];
    final optimizedTrajectory = <double>[];
    
    // Simple 4% annual return on savings (0.33% monthly) for optimized trajectory
    final monthlyReturnRate = 0.04 / 12;

    double runningCurrent = currentSavings;
    double runningOptimized = currentSavings;

    for (int i = 0; i < 12; i++) {
      runningCurrent += currentMonthlySavings;
      
      runningOptimized += optimizedMonthlySavings;
      runningOptimized += (runningOptimized * monthlyReturnRate); // Compound interest on optimized
      
      currentTrajectory.add(runningCurrent);
      optimizedTrajectory.add(runningOptimized);
    }

    // 4. Generate Recommendations
    final recommendations = <String>[];
    if (wantsSpend > monthlyIncome * 0.3) {
      recommendations.add('Reduce discretionary spending (Shopping, Dining) by 30% to unlock massive growth.');
    }
    if (currentMonthlySavings < monthlyIncome * 0.2) {
      recommendations.add('Your current savings rate is below the recommended 20%. Try the 50/30/20 budget rule.');
    }
    final difference = runningOptimized - runningCurrent;
    if (difference > 1000) {
      recommendations.add('By optimizing your behavior, you could gain an extra ₹${difference.toStringAsFixed(0)} in 12 months.');
    }

    return TwinSimulationResult(
      currentTrajectory: currentTrajectory,
      optimizedTrajectory: optimizedTrajectory,
      monthLabels: _generateMonthLabels(12),
      currentNetWorth: currentTrajectory.last,
      optimizedNetWorth: optimizedTrajectory.last,
      recommendations: recommendations.isNotEmpty ? recommendations : ['Keep up the great financial habits!'],
    );
  }

  static List<String> _generateMonthLabels(int count) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currentMonth = DateTime.now().month - 1; // 0-indexed
    final labels = <String>[];
    
    for (int i = 0; i < count; i++) {
      labels.add(months[(currentMonth + i + 1) % 12]);
    }
    return labels;
  }
}
