import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../database/collections/transaction_collection.dart';
import '../../transactions/widgets/transaction_card.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({
    super.key,
    required this.transactions,
  });

  final List<TransactionCollection> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: transactions.map((tx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: TransactionCard(transaction: tx),
        );
      }).toList(),
    );
  }
}
