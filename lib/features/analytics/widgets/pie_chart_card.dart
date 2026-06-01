import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/cards/kosh_card.dart';
import '../models/category_summary.dart';
import 'category_breakdown_tile.dart';

class PieChartCard extends StatelessWidget {
  const PieChartCard({
    super.key,
    required this.title,
    required this.data,
  });

  final String title;
  final List<CategorySummary> data;

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
            const Center(child: Text('No data for this period.', style: TextStyle(color: AppColors.textSecondary))),
          ],
        ),
      );
    }

    return KoshCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: data.map((e) {
                        return PieChartSectionData(
                          color: e.color,
                          value: e.percentage,
                          title: '',
                          radius: 30,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: data.map((e) => CategoryBreakdownTile(summary: e)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
