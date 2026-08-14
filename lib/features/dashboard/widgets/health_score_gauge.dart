import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthScoreGauge extends StatelessWidget {
  final double score;
  final double savingsRate;
  final String riskLevel;
  final double trendPercentage;
  final bool hasExpenses;

  const HealthScoreGauge({
    super.key,
    required this.score,
    this.savingsRate = 0.0,
    this.riskLevel = 'Medium',
    this.trendPercentage = 0.0,
    this.hasExpenses = true,
  });

  Color _getColor() {
    if (!hasExpenses) return Colors.blueGrey;
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getLabel() {
    if (!hasExpenses) return 'No Expenses Yet';
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? null
            : [
                const BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Financial Health',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 58,
                        borderData: FlBorderData(show: false),
                        sections: [
                          PieChartSectionData(
                            value: hasExpenses ? score : 0,
                            color: color,
                            radius: 32,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: hasExpenses ? (100 - score) : 100,
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            radius: 32,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasExpenses ? score.toInt().toString() : '0',
                          style: TextStyle(
                            color: color,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),

                        Text(
                          '/100',
                          style: TextStyle(
                            color: color.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              _getLabel(),
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 28),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: [
                _metricTile(
                  context: context,
                  icon: Icons.savings,
                  title: 'Savings',
                  value: hasExpenses ? '${savingsRate.toStringAsFixed(0)}%' : '0%',
                  color: !hasExpenses ? Colors.blueGrey : (savingsRate >= 20 ? Colors.greenAccent : (savingsRate >= 10 ? Colors.orangeAccent : Colors.redAccent)),
                ),

                _metricTile(
                  context: context,
                  icon: Icons.shield,
                  title: 'Risk',
                  value: hasExpenses ? riskLevel : 'N/A',
                  color: !hasExpenses ? Colors.blueGrey : (riskLevel == 'Low' ? Colors.greenAccent : (riskLevel == 'High' ? Colors.redAccent : Colors.orangeAccent)),
                ),

                _metricTile(
                  context: context,
                  icon: Icons.trending_up,
                  title: 'Trend',
                  value: hasExpenses ? '${trendPercentage >= 0 ? '+' : ''}${trendPercentage.toStringAsFixed(0)}%' : '0%',
                  color: !hasExpenses ? Colors.blueGrey : (trendPercentage <= 0 ? Colors.greenAccent : Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              fontSize: 14,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}