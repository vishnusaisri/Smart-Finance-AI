import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthScoreGauge extends StatelessWidget {
  final double score;

  const HealthScoreGauge({
    super.key,
    required this.score,
  });

  Color _getColor() {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getLabel() {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Financial Health',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
                          value: score,
                          color: color,
                          radius: 32,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 100 - score,
                          color: const Color(0xFF1E293B),
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
                        score.toInt().toString(),
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
                icon: Icons.savings,
                title: 'Savings',
                value: '24%',
                color: Colors.greenAccent,
              ),

              _metricTile(
                icon: Icons.shield,
                title: 'Risk',
                value: 'Medium',
                color: Colors.orangeAccent,
              ),

              _metricTile(
                icon: Icons.trending_up,
                title: 'Trend',
                value: '+12%',
                color: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }

  Widget _metricTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}