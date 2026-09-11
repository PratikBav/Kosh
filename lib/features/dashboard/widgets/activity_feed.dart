import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../database/collections/transaction_collection.dart';
import '../../../../shared/cards/kosh_card.dart';
import '../../transactions/widgets/transaction_card.dart';

/// Recent transactions on the dashboard.
///
/// Uses the same [TransactionCard] row as the transactions list. It previously
/// drew its own card on a timeline rail, so an identical record looked like
/// two different things depending on the screen, and the rail added structure
/// that five chronological rows did not need.
class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key, required this.transactions});

  final List<TransactionCollection> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const KoshCard(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Center(
          child: Text(
            'No activity yet. Add a transaction to get started.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < transactions.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          TransactionCard(
            transaction: transactions[i],
            onTap: () => context.goNamed(
              RouteConstants.transactionDetails,
              pathParameters: {'id': transactions[i].id.toString()},
            ),
          ),
        ],
      ],
    );
  }
}
