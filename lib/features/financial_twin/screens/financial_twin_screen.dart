import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/models/expense.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../profile/providers/profile_providers.dart';
import '../services/twin_simulator_engine.dart';
import '../services/twin_service.dart';

class FinancialTwinScreen extends ConsumerStatefulWidget {
  const FinancialTwinScreen({super.key});

  @override
  ConsumerState<FinancialTwinScreen> createState() => _FinancialTwinScreenState();
}

class _FinancialTwinScreenState extends ConsumerState<FinancialTwinScreen> {
  // Granular expense controls
  double _foodSpending = 1.0; // multiplier
  double _shoppingSpending = 1.0; // multiplier
  double _sipInvestment = 0.0; // additional monthly SIP
  double _emiReduction = 0.0; // percentage reduction
  double _subscriptionCleanup = 0.0; // percentage of subscriptions to cancel
  double _savingsRate = 0.2; // target savings rate
  
  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final twinService = ref.watch(twinServiceProvider);
    final userProfile = ref.watch(userProfileProvider);
    
    // Get real user data from profile
    final monthlyIncome = userProfile.monthlyIncome;
    final currencySymbol = userProfile.getCurrencySymbol();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Twin Simulator'),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error', style: TextStyle(color: Colors.white))),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('Need more data to run simulation.', style: TextStyle(color: Colors.white)));
          }

          final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
          final startingSavings = (monthlyIncome - totalExpenses).clamp(0.0, double.infinity);

          // Calculate behavioral insights
          final behavioralInsights = _calculateBehavioralInsights(expenses, monthlyIncome);
          final primaryInsight = behavioralInsights.isNotEmpty ? behavioralInsights.first : <String, dynamic>{};
          
          // Adjust expenses based on granular controls
          final adjustedExpenses = _adjustExpenses(expenses);

          final simulation = TwinSimulatorEngine.simulateFuture(
            currentSavings: startingSavings,
            monthlyIncome: monthlyIncome,
            pastExpenses: adjustedExpenses,
            savingsRate: _savingsRate,
          );

          // Save simulation async in background
          twinService.saveSimulationResult(simulation);

          // Premium layout: Left controls, Right simulation
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              
              if (isMobile) {
                // Mobile: Vertical layout
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Control Your Future',
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Adjust lifestyle parameters to see real-time impact on your financial future.',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Granular Sliders
                      _buildPremiumSlider(
                        icon: Icons.restaurant,
                        label: 'Food & Dining',
                        value: _foodSpending,
                        min: 0.5,
                        max: 1.5,
                        divisions: 10,
                        suffix: 'x',
                        description: 'Adjust food delivery and dining spending',
                        onChanged: (value) {
                          setState(() {
                            _foodSpending = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildPremiumSlider(
                        icon: Icons.shopping_bag,
                        label: 'Shopping',
                        value: _shoppingSpending,
                        min: 0.5,
                        max: 1.5,
                        divisions: 10,
                        suffix: 'x',
                        description: 'Adjust shopping and discretionary spending',
                        onChanged: (value) {
                          setState(() {
                            _shoppingSpending = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildPremiumSlider(
                        icon: Icons.trending_up,
                        label: 'SIP Investment',
                        value: _sipInvestment,
                        min: 0,
                        max: 10000,
                        divisions: 20,
                        suffix: '/mo',
                        description: 'Additional monthly SIP investment',
                        onChanged: (value) {
                          setState(() {
                            _sipInvestment = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildPremiumSlider(
                        icon: Icons.account_balance,
                        label: 'EMI Reduction',
                        value: _emiReduction,
                        min: 0,
                        max: 0.5,
                        divisions: 10,
                        suffix: '%',
                        description: 'Reduce loan EMI through prepayment',
                        onChanged: (value) {
                          setState(() {
                            _emiReduction = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildPremiumSlider(
                        icon: Icons.subscriptions,
                        label: 'Subscription Cleanup',
                        value: _subscriptionCleanup,
                        min: 0,
                        max: 1.0,
                        divisions: 10,
                        suffix: '%',
                        description: 'Cancel unused subscriptions',
                        onChanged: (value) {
                          setState(() {
                            _subscriptionCleanup = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _buildPremiumSlider(
                        icon: Icons.savings,
                        label: 'Target Savings Rate',
                        value: _savingsRate,
                        min: 0.1,
                        max: 0.5,
                        divisions: 8,
                        suffix: '%',
                        description: 'Percentage of income to save monthly',
                        onChanged: (value) {
                          setState(() {
                            _savingsRate = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Simulation Results
                      Text(
                        'Future Projection',
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Dual Timeline Comparison
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimelineCard(
                              'Current Path',
                              simulation.currentNetWorth,
                              Colors.orange,
                              primaryInsight['stress']?.toString() ?? 'Moderate',
                              currencySymbol,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildTimelineCard(
                              'Optimized Path',
                              simulation.optimizedNetWorth,
                              const Color(0xFF06B6D4),
                              'Stable',
                              currencySymbol,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Animated Chart
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('12-Month Trajectory', style: AppTextStyles.h5.copyWith(color: Colors.white)),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              height: 250,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 1000,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.white.withOpacity(0.1),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 && value.toInt() < simulation.monthLabels.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                simulation.monthLabels[value.toInt()],
                                                style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() % 2000 == 0) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Text(
                                                '₹${(value.toInt() / 1000).toInt()}k',
                                                style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        simulation.currentTrajectory.length,
                                        (i) => FlSpot(i.toDouble(), safeDouble(simulation.currentTrajectory[i])),
                                      ),
                                      isCurved: true,
                                      color: Colors.orange,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.orange.withOpacity(0.1),
                                      ),
                                    ),
                                    LineChartBarData(
                                      spots: List.generate(
                                        simulation.optimizedTrajectory.length,
                                        (i) => FlSpot(i.toDouble(), safeDouble(simulation.optimizedTrajectory[i])),
                                      ),
                                      isCurved: true,
                                      color: const Color(0xFF06B6D4),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(0xFF06B6D4).withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: AppSpacing.xxl),

                      // AI Coaching Layer
                      Text(
                        'AI Financial Coach',
                        style: AppTextStyles.h4.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildAICoachingCard(simulation, primaryInsight, currencySymbol),
                      const SizedBox(height: AppSpacing.xxl),

                      // Scenario Comparison Table
                      Text(
                        'Scenario Analysis',
                        style: AppTextStyles.h4.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildScenarioTable(simulation, monthlyIncome, expenses, currencySymbol),
                    ],
                  ),
                );
              }

              // Desktop/Tablet: Split layout
              return Row(
                children: [
                  // LEFT SIDE: Controls
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Control Your Future',
                              style: AppTextStyles.h2.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Adjust lifestyle parameters to see real-time impact on your financial future.',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                        // Granular Sliders
                            _buildPremiumSlider(
                              icon: Icons.restaurant,
                              label: 'Food & Dining',
                              value: _foodSpending,
                              min: 0.5,
                              max: 1.5,
                              divisions: 10,
                              suffix: 'x',
                              description: 'Adjust food delivery and dining spending',
                              onChanged: (value) {
                                setState(() {
                                  _foodSpending = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            _buildPremiumSlider(
                              icon: Icons.shopping_bag,
                              label: 'Shopping',
                              value: _shoppingSpending,
                              min: 0.5,
                              max: 1.5,
                              divisions: 10,
                              suffix: 'x',
                              description: 'Adjust shopping and discretionary spending',
                              onChanged: (value) {
                                setState(() {
                                  _shoppingSpending = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            _buildPremiumSlider(
                              icon: Icons.trending_up,
                              label: 'SIP Investment',
                              value: _sipInvestment,
                              min: 0,
                              max: 10000,
                              divisions: 20,
                              suffix: '/mo',
                              description: 'Additional monthly SIP investment',
                              onChanged: (value) {
                                setState(() {
                                  _sipInvestment = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            _buildPremiumSlider(
                              icon: Icons.account_balance,
                              label: 'EMI Reduction',
                              value: _emiReduction,
                              min: 0,
                              max: 0.5,
                              divisions: 10,
                              suffix: '%',
                              description: 'Reduce loan EMI through prepayment',
                              onChanged: (value) {
                                setState(() {
                                  _emiReduction = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            _buildPremiumSlider(
                              icon: Icons.subscriptions,
                              label: 'Subscription Cleanup',
                              value: _subscriptionCleanup,
                              min: 0,
                              max: 1.0,
                              divisions: 10,
                              suffix: '%',
                              description: 'Cancel unused subscriptions',
                              onChanged: (value) {
                                setState(() {
                                  _subscriptionCleanup = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            _buildPremiumSlider(
                              icon: Icons.savings,
                              label: 'Target Savings Rate',
                              value: _savingsRate,
                              min: 0.1,
                              max: 0.5,
                              divisions: 8,
                              suffix: '%',
                              description: 'Percentage of income to save monthly',
                              onChanged: (value) {
                                setState(() {
                                  _savingsRate = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // Behavioral Finance Insights
                            Text(
                              'Behavioral Insights',
                              style: AppTextStyles.h4.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (behavioralInsights.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _buildBehavioralInsightCard(behavioralInsights.first),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1, color: Color(0x1AFFFFFF)),

                  // RIGHT SIDE: Simulation
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Future Projection',
                              style: AppTextStyles.h2.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Real-time simulation of your financial trajectory',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // Dual Timeline Comparison
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimelineCard(
                                    'Current Path',
                                    simulation.currentNetWorth,
                                    Colors.orange,
                                    primaryInsight['stress']?.toString() ?? 'Moderate',
                                    currencySymbol,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _buildTimelineCard(
                                    'Optimized Path',
                                    simulation.optimizedNetWorth,
                                    const Color(0xFF06B6D4),
                                    'Stable',
                                    currencySymbol,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // Animated Chart
                            GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('12-Month Trajectory', style: AppTextStyles.h5.copyWith(color: Colors.white)),
                                      Row(
                                        children: [
                                          _buildLegendItem('Current', Colors.orange),
                                          const SizedBox(width: AppSpacing.md),
                                          _buildLegendItem('Optimized', const Color(0xFF06B6D4)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  SizedBox(
                                    height: 350,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: 1000,
                                          getDrawingHorizontalLine: (value) => FlLine(
                                            color: Colors.white.withOpacity(0.1),
                                            strokeWidth: 1,
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() >= 0 && value.toInt() < simulation.monthLabels.length) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: Text(
                                                      simulation.monthLabels[value.toInt()],
                                                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() % 2000 == 0) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 8.0),
                                                    child: Text(
                                                      '₹${(value.toInt() / 1000).toInt()}k',
                                                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: List.generate(
                                              simulation.currentTrajectory.length,
                                              (i) => FlSpot(i.toDouble(), safeDouble(simulation.currentTrajectory[i])),
                                            ),
                                            isCurved: true,
                                            color: Colors.orange,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: Colors.orange.withOpacity(0.1),
                                            ),
                                          ),
                                          LineChartBarData(
                                            spots: List.generate(
                                              simulation.optimizedTrajectory.length,
                                              (i) => FlSpot(i.toDouble(), safeDouble(simulation.optimizedTrajectory[i])),
                                            ),
                                            isCurved: true,
                                            color: const Color(0xFF06B6D4),
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: const FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: const Color(0xFF06B6D4).withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                            const SizedBox(height: AppSpacing.xxl),

                            // AI Coaching Layer
                            Text(
                              'AI Financial Coach',
                              style: AppTextStyles.h4.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildAICoachingCard(simulation, primaryInsight, currencySymbol),
                            const SizedBox(height: AppSpacing.xxl),

                            // Scenario Comparison Table
                            Text(
                              'Scenario Analysis',
                              style: AppTextStyles.h4.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildScenarioTable(simulation, monthlyIncome, expenses, currencySymbol),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
      ],
    );
  }

  // Helper methods for premium UI
  List<Map<String, dynamic>> _calculateBehavioralInsights(List<Expense> expenses, double monthlyIncome) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentExpenses = expenses.where((e) => e.date.isAfter(thirtyDaysAgo)).toList();
    
    // Calculate behavioral patterns
    final weekendExpenses = recentExpenses.where((e) {
      final day = e.date.weekday;
      return day == DateTime.saturday || day == DateTime.sunday;
    }).fold<double>(0, (sum, e) => sum + e.amount);
    
    final impulseExpenses = recentExpenses.where((e) => e.isImpulse).fold<double>(0, (sum, e) => sum + e.amount);
    
    final subscriptionExpenses = recentExpenses.where((e) => e.category == 'Subscriptions').fold<double>(0, (sum, e) => sum + e.amount);
    
    final totalMonthlySpend = recentExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final stressLevel = totalMonthlySpend > monthlyIncome * 0.9 ? 'High' : totalMonthlySpend > monthlyIncome * 0.7 ? 'Moderate' : 'Low';
    
    return [
      {
        'weekend_overspending': weekendExpenses > totalMonthlySpend * 0.4,
        'impulse_ratio': impulseExpenses / totalMonthlySpend,
        'subscription_leakage': subscriptionExpenses,
        'stress': stressLevel,
        'total_spend': totalMonthlySpend,
      }
    ];
  }

  List<Expense> _adjustExpenses(List<Expense> expenses) {
    return expenses.map((e) {
      double adjustedAmount = e.amount;
      
      // Apply category-specific adjustments
      if (e.category == 'Food & Dining' || e.category == 'Food') {
        adjustedAmount *= _foodSpending;
      } else if (e.category == 'Shopping') {
        adjustedAmount *= _shoppingSpending;
      } else if (e.category == 'Subscriptions') {
        adjustedAmount *= (1 - _subscriptionCleanup);
      } else if (e.category.contains('Loan') || e.category.contains('EMI')) {
        adjustedAmount *= (1 - _emiReduction);
      }
      
      return e.copyWith(amount: adjustedAmount);
    }).toList();
  }

  Widget _buildPremiumSlider({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required String description,
    required ValueChanged<double> onChanged,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF06B6D4), size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(label, style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              ),
              Text(
                suffix == '%' ? '${(value * 100).toStringAsFixed(0)}$suffix' : '${value.toStringAsFixed(0)}$suffix',
                style: AppTextStyles.h5.copyWith(color: const Color(0xFF06B6D4)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF06B6D4),
              inactiveTrackColor: const Color(0xFF06B6D4).withOpacity(0.2),
              thumbColor: const Color(0xFF06B6D4),
              overlayColor: const Color(0xFF06B6D4).withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehavioralInsightCard(Map<String, dynamic> insight) {
    return GlassCard(
      child: Row(
        children: [
          Icon(
            insight['weekend_overspending'] == true ? Icons.weekend : 
            insight['impulse_ratio'] > 0.2 ? Icons.flash_on : 
            Icons.info_outline,
            color: insight['weekend_overspending'] == true || insight['impulse_ratio'] > 0.2 
                ? Colors.orange 
                : const Color(0xFF06B6D4),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              insight['weekend_overspending'] == true 
                  ? 'Weekend spending is high' 
                  : insight['impulse_ratio'] > 0.2 
                      ? 'Impulse purchases: ${((insight['impulse_ratio'] as double) * 100).toStringAsFixed(0)}% of spending'
                      : 'Subscription leakage: ₹${(insight['subscription_leakage'] as double).toStringAsFixed(0)}/mo',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(String title, double amount, Color color, String status, String currencySymbol) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'High' ? Colors.red.withOpacity(0.2) : 
                         status == 'Moderate' ? Colors.orange.withOpacity(0.2) : 
                         Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: status == 'High' ? Colors.red : 
                           status == 'Moderate' ? Colors.orange : 
                           Colors.green,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$currencySymbol${amount.toStringAsFixed(0)}',
              style: AppTextStyles.h2.copyWith(color: color),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '12-month projection',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachingCard(TwinSimulationResult simulation, Map<String, dynamic> behavioralInsights, String currencySymbol) {
    final improvement = simulation.optimizedNetWorth - simulation.currentNetWorth;
    final improvementPercent = simulation.currentNetWorth > 0 
        ? (improvement / simulation.currentNetWorth * 100).abs() 
        : 0.0;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF06B6D4), size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  improvement > 0 
                      ? 'If you optimize your spending habits, you could build an additional $currencySymbol${improvement.toStringAsFixed(0)} in wealth over 12 months (${improvementPercent.toStringAsFixed(0)}% improvement).'
                      : 'Your current trajectory is strong. Maintain your disciplined approach to continue building wealth.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (behavioralInsights['weekend_overspending'] == true)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Consider setting a weekend budget to reduce discretionary spending.',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildScenarioTable(TwinSimulationResult simulation, double monthlyIncome, List<Expense> expenses, String currencySymbol) {
    final foodExpenses = expenses
        .where((e) => e.category.toLowerCase().contains('food') || e.category.toLowerCase().contains('dining'))
        .fold<double>(0, (sum, e) => sum + e.amount);
    final annualFoodSavings = (foodExpenses * 0.20) * 12;
    final foodOptWorth = simulation.currentNetWorth + annualFoodSavings;

    final sipAmount = _sipInvestment > 0 ? _sipInvestment : 5000.0;
    final sipOptWorth = simulation.currentNetWorth + (sipAmount * 12.68);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What-If Scenarios', style: AppTextStyles.h5.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.lg),
          _buildScenarioRow('Current Lifestyle', simulation.currentNetWorth, Colors.orange, currencySymbol),
          const Divider(color: Color(0x1AFFFFFF)),
          _buildScenarioRow('Reduce Food 20%', foodOptWorth, const Color(0xFF06B6D4), currencySymbol),
          const Divider(color: Color(0x1AFFFFFF)),
          _buildScenarioRow('SIP $currencySymbol${sipAmount.toStringAsFixed(0)}/mo', sipOptWorth, Colors.green, currencySymbol),
          const Divider(color: Color(0x1AFFFFFF)),
          _buildScenarioRow('Full Optimization', simulation.optimizedNetWorth, const Color(0xFF8B5CF6), currencySymbol),
        ],
      ),
    );
  }

  Widget _buildScenarioRow(String label, double amount, Color color, String currencySymbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
          Text(
            '$currencySymbol${amount.toStringAsFixed(0)}',
            style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

