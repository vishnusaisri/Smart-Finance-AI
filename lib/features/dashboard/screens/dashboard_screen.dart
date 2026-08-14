import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/expense.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_strings.dart';

import '../../expense/controllers/expense_controller.dart';
import '../../profile/providers/profile_providers.dart';
import '../controllers/ai_insights_controller.dart';

import '../widgets/financial_overview_card.dart';
import '../widgets/health_score_gauge.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/expense_breakdown_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/ai_insights_feed.dart';
import '../widgets/savings_goals_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final insightsAsync = ref.watch(aiInsightsProvider);
    final userProfile = ref.watch(userProfileProvider);

    final monthlyIncome = userProfile.monthlyIncome;

    return expensesAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),

      error: (error, stackTrace) =>
          Center(child: Text('Error: $error')),

      data: (expenses) {
        // Calculate health score based on real financial data
        final totalExpenses = expenses.fold<double>(
          0,
          (sum, exp) => sum + exp.amount,
        );

        final hasExpenses = expenses.isNotEmpty;
        final savings = monthlyIncome - totalExpenses;
        final savingsRate = hasExpenses
            ? (monthlyIncome > 0 ? (savings / monthlyIncome * 100) : 0.0)
            : 0.0;
        final healthScore = _calculateHealthScore(savingsRate, totalExpenses, monthlyIncome, !hasExpenses);
        final riskLevel = hasExpenses ? _calculateRiskLevel(savingsRate, totalExpenses, monthlyIncome) : 'N/A';
        final spendingTrend = _calculateSpendingTrend(expenses, monthlyIncome);

        final categoryBreakdown = <String, double>{};

        for (final expense in expenses) {
          categoryBreakdown[expense.category] =
              (categoryBreakdown[expense.category] ?? 0) +
                  expense.amount;
        }

        // Calculate real monthly trend from actual expense data
        final monthlyTrend = <Map<String, dynamic>>[];
        if (expenses.isNotEmpty) {
          final now = DateTime.now();
          final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          for (int i = 5; i >= 0; i--) {
            final targetYear = now.month - i <= 0 ? now.year - 1 : now.year;
            final targetMonth = ((now.month - 1 - i) % 12 + 12) % 12 + 1;
            
            final monthTotal = expenses.where((exp) =>
              exp.date.year == targetYear && exp.date.month == targetMonth
            ).fold<double>(0.0, (sum, exp) => sum + exp.amount);

            monthlyTrend.add({
              'month': monthNames[targetMonth - 1],
              'amount': monthTotal,
              'expenses': monthTotal,
              'income': monthlyIncome,
            });
          }
        }

        return insightsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),

          error: (error, stack) =>
              Center(child: Text('Error: $error')),

          data: (insights) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isTablet = screenWidth < 1200 && screenWidth >= 768;
                final isMobile = screenWidth < 768;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMobile ? AppSpacing.md : AppSpacing.xl,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Welcome back, ${userProfile.fullName}!',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: isMobile ? 20 : 24,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.2, end: 0),

                      const SizedBox(
                        height: AppSpacing.xs,
                      ),

                      Text(
                        'Here\'s your financial overview',
                        style: AppTextStyles.bodySmall,
                      )
                          .animate()
                          .fadeIn(
                            delay: 100.ms,
                            duration: 400.ms,
                          ),

                      SizedBox(
                        height: isMobile ? AppSpacing.lg : AppSpacing.xl,
                      ),

                      _buildOverviewCards(
                        savings: savings,
                        userIncome: monthlyIncome,
                        totalExpenses: totalExpenses,
                        isMobile: isMobile,
                      )
                          .animate()
                          .fadeIn(
                            delay: 200.ms,
                            duration: 500.ms,
                          )
                          .slideY(begin: 0.1, end: 0)
                          .shimmer(duration: 1200.ms),

                      SizedBox(
                        height: isMobile ? AppSpacing.lg : AppSpacing.xl,
                      ),

                      _buildInsightsAndHealthRow(
                        insights: insights,
                        healthScore: healthScore,
                        savingsRate: savingsRate,
                        riskLevel: riskLevel,
                        spendingTrend: spendingTrend,
                        hasExpenses: hasExpenses,
                        userGoals:
                            userProfile.goals ?? [],
                        isTablet: isTablet,
                        isMobile: isMobile,
                      )
                          .animate()
                          .fadeIn(
                            delay: 300.ms,
                            duration: 500.ms,
                          )
                          .slideY(begin: 0.1, end: 0)
                          .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1)),

                      SizedBox(
                        height: isMobile ? AppSpacing.lg : AppSpacing.xl,
                      ),

                      _buildChartsRow(
                        categoryBreakdown:
                            categoryBreakdown,
                        expenses: expenses,
                        isTablet: isTablet,
                        isMobile: isMobile,
                      )
                          .animate()
                          .fadeIn(
                            delay: 400.ms,
                            duration: 500.ms,
                          )
                          .slideY(begin: 0.1, end: 0),

                      SizedBox(
                        height: isMobile ? AppSpacing.lg : AppSpacing.xl,
                      ),

                      _buildMonthlyTrendChart(
                        monthlyTrend: monthlyTrend,
                        isMobile: isMobile,
                      )
                          .animate()
                          .fadeIn(
                            delay: 500.ms,
                            duration: 600.ms,
                          )
                          .slideY(begin: 0.1, end: 0),

                      SizedBox(
                        height: isMobile ? AppSpacing.lg : AppSpacing.xl,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  double _calculateHealthScore(double savingsRate, double totalExpenses, double monthlyIncome, [bool hasNoExpenses = false]) {
    if (monthlyIncome == 0 || hasNoExpenses) return 0.0;
    
    double score = 50.0;
    
    // Savings rate contribution (up to 30 points)
    if (savingsRate >= 20) score += 30;
    else if (savingsRate >= 15) score += 25;
    else if (savingsRate >= 10) score += 20;
    else if (savingsRate >= 5) score += 10;
    else if (savingsRate < 0) score -= 10;
    
    // Expense ratio contribution (up to 20 points)
    final expenseRatio = monthlyIncome > 0 ? (totalExpenses / monthlyIncome) * 100 : 100;
    if (expenseRatio <= 70) score += 20;
    else if (expenseRatio <= 80) score += 15;
    else if (expenseRatio <= 90) score += 10;
    else if (expenseRatio > 100) score -= 10;
    
    return score.clamp(0.0, 100.0);
  }

  String _calculateRiskLevel(double savingsRate, double totalExpenses, double monthlyIncome) {
    if (monthlyIncome == 0) return 'Medium';
    
    final expenseRatio = monthlyIncome > 0 ? (totalExpenses / monthlyIncome) * 100 : 100;
    
    if (savingsRate >= 20 && expenseRatio <= 70) return 'Low';
    if (savingsRate >= 10 && expenseRatio <= 80) return 'Low';
    if (savingsRate >= 5 && expenseRatio <= 90) return 'Medium';
    if (expenseRatio > 100) return 'High';
    return 'Medium';
  }

  double _calculateSpendingTrend(List<dynamic> expenses, double monthlyIncome) {
    if (expenses.isEmpty || monthlyIncome == 0) return 0.0;
    
    final now = DateTime.now();
    final prevMonthStart = DateTime(now.month == 1 ? now.year - 1 : now.year, now.month == 1 ? 12 : now.month - 1, 1);
    
    final currentMonthExpenses = expenses
        .whereType<Expense>()
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.amount);
        
    final prevMonthExpenses = expenses
        .whereType<Expense>()
        .where((e) => e.date.year == prevMonthStart.year && e.date.month == prevMonthStart.month)
        .fold<double>(0, (sum, e) => sum + e.amount);
    
    if (prevMonthExpenses == 0) return 0.0;
    return ((currentMonthExpenses - prevMonthExpenses) / prevMonthExpenses) * 100;
  }

  double _calculateImprovementPercentage(double currentHealthScore, List<dynamic> expenses, double monthlyIncome) {
    if (expenses.isEmpty || monthlyIncome == 0) return 0.0;
    
    final now = DateTime.now();
    final prevMonthStart = DateTime(now.month == 1 ? now.year - 1 : now.year, now.month == 1 ? 12 : now.month - 1, 1);
    
    final prevMonthExpenses = expenses
        .whereType<Expense>()
        .where((e) => e.date.year == prevMonthStart.year && e.date.month == prevMonthStart.month)
        .fold<double>(0, (sum, e) => sum + e.amount);
        
    if (prevMonthExpenses == 0) return 0.0;
    
    final prevSavings = monthlyIncome - prevMonthExpenses;
    final prevSavingsRate = (prevSavings / monthlyIncome) * 100;
    final prevHealthScore = _calculateHealthScore(prevSavingsRate, prevMonthExpenses, monthlyIncome);
    
    return currentHealthScore - prevHealthScore;
  }

  Widget _buildOverviewCards({
    required double savings,
    required double userIncome,
    required double totalExpenses,
    required bool isMobile,
  }) {
    // Calculate realistic trends based on data
    final balanceTrend = userIncome > 0 ? ((savings / userIncome) * 100) : 0.0;
    final expenseTrend = userIncome > 0 ? ((totalExpenses / userIncome) * 100) : 0.0;

    if (isMobile) {
      return Column(
        children: [
          FinancialOverviewCard(
            title: AppStrings.totalBalance,
            amount: savings,
            subtitle: 'Current savings',
            icon: Icons.account_balance_wallet,
            trend: balanceTrend > 0 ? balanceTrend.toDouble() : 0.0,
          ),

          const SizedBox(
            height: AppSpacing.gridGap,
          ),

          FinancialOverviewCard(
            title: AppStrings.monthlyIncome,
            amount: userIncome,
            subtitle: 'This month',
            icon: Icons.trending_up,
            trend: 0.0,
          ),

          const SizedBox(
            height: AppSpacing.gridGap,
          ),

          FinancialOverviewCard(
            title: AppStrings.monthlyExpenses,
            amount: totalExpenses,
            subtitle: 'This month',
            icon: Icons.trending_down,
            trend: expenseTrend > 0 ? -expenseTrend.toDouble() : 0.0,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: FinancialOverviewCard(
            title: AppStrings.totalBalance,
            amount: savings,
            subtitle: 'Current savings',
            icon: Icons.account_balance_wallet,
            trend: balanceTrend > 0 ? balanceTrend.toDouble() : 0.0,
          ),
        ),

        const SizedBox(
          width: AppSpacing.gridGap,
        ),

        Expanded(
          child: FinancialOverviewCard(
            title: AppStrings.monthlyIncome,
            amount: userIncome,
            subtitle: 'This month',
            icon: Icons.trending_up,
            trend: 0.0,
          ),
        ),

        const SizedBox(
          width: AppSpacing.gridGap,
        ),

        Expanded(
          child: FinancialOverviewCard(
            title: AppStrings.monthlyExpenses,
            amount: totalExpenses,
            subtitle: 'This month',
            icon: Icons.trending_down,
            trend: expenseTrend > 0 ? -expenseTrend.toDouble() : 0.0,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsAndHealthRow({
    required List<dynamic> insights,
    required double healthScore,
    required double savingsRate,
    required String riskLevel,
    required double spendingTrend,
    required bool hasExpenses,
    required List<FinancialGoal> userGoals,
    required bool isTablet,
    required bool isMobile,
  }) {
    final goals = userGoals;

    if (isMobile) {
      return Column(
        children: [
          const AIInsightsFeed(),

          const SizedBox(
            height: AppSpacing.gridGap,
          ),

          Container(
            constraints: const BoxConstraints(
              minHeight: 380,
            ),
            child: HealthScoreGauge(
              score: healthScore,
              savingsRate: savingsRate,
              riskLevel: riskLevel,
              trendPercentage: spendingTrend,
              hasExpenses: hasExpenses,
            ),
          ),

          const SizedBox(
            height: AppSpacing.gridGap,
          ),

          SavingsGoalsCard(
            goals: goals,
          ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          const AIInsightsFeed(),

          const SizedBox(
            height: AppSpacing.gridGap,
          ),

          Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 400,
                  ),
                  child: HealthScoreGauge(
                    score: healthScore,
                    savingsRate: savingsRate,
                    riskLevel: riskLevel,
                    trendPercentage: spendingTrend,
                    hasExpenses: hasExpenses,
                  ),
                ),
              ),

              const SizedBox(
                width: AppSpacing.gridGap,
              ),

              Expanded(
                child: SavingsGoalsCard(
                  goals: goals,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: const AIInsightsFeed(),
        ),

        const SizedBox(
          width: AppSpacing.gridGap,
        ),

        Expanded(
          flex: 1,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 420,
            ),
            child: HealthScoreGauge(
              score: healthScore,
              savingsRate: savingsRate,
              riskLevel: riskLevel,
              trendPercentage: spendingTrend,
              hasExpenses: hasExpenses,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow({
    required Map<String, double>
        categoryBreakdown,
    required List<dynamic> expenses,
    required bool isTablet,
    required bool isMobile,
  }) {
    final expenseList =
        expenses.whereType<Expense>().toList();

    if (isMobile) {
      return Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  AppStrings.expenseBreakdown,
                  style: AppTextStyles.h5,
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                ExpenseBreakdownChart(
                  categoryBreakdown:
                      categoryBreakdown,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppSpacing.gridGap,
          ),

          RecentTransactionsList(
            expenses:
                expenseList.take(5).toList(),
          ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  AppStrings.expenseBreakdown,
                  style: AppTextStyles.h5,
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                ExpenseBreakdownChart(
                  categoryBreakdown:
                      categoryBreakdown,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppSpacing.gridGap,
          ),

          RecentTransactionsList(
            expenses:
                expenseList.take(8).toList(),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Expanded(
          child: GlassCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  AppStrings.expenseBreakdown,
                  style: AppTextStyles.h5,
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                ExpenseBreakdownChart(
                  categoryBreakdown:
                      categoryBreakdown,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(
          width: AppSpacing.gridGap,
        ),

        Expanded(
          child: RecentTransactionsList(
            expenses:
                expenseList.take(8).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendChart({
    required List<Map<String, dynamic>>
        monthlyTrend,
    required bool isMobile,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Text(
                AppStrings.monthlyTrend,
                style: AppTextStyles.h5,
              ),

              Text(
                'Last 6 months',
                style: AppTextStyles.caption,
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          MonthlyTrendChart(
            data: monthlyTrend,
          ),
        ],
      ),
    );
  }
}