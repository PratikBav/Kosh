import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/cards/kosh_card.dart';
import '../models/monthly_summary.dart';

class TrendChartCard extends StatelessWidget {
  const TrendChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.isSavingsRate,
  });

  final String title;
  final List<MonthlySummary> data;
  final bool isSavingsRate;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return KoshCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.lg),
            const Center(child: Text('Not enough data.', style: TextStyle(color: AppColors.textSecondary))),
          ],
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final val = isSavingsRate ? data[i].savingsRate : data[i].expense;
      spots.add(FlSpot(i.toDouble(), val));
    }

    final maxY = spots.isEmpty ? 10.0 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2;

    return KoshCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox();
                        final d = data[idx];
                        final monthStr = DateFormat('MMM').format(DateTime(d.year, d.month));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(monthStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxY == 0 ? 100 : maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: isSavingsRate ? AppColors.secondary : AppColors.danger,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (isSavingsRate ? AppColors.secondary : AppColors.danger).withValues(alpha: 0.4),
                          (isSavingsRate ? AppColors.secondary : AppColors.danger).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
