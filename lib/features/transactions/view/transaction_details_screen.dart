import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/cards/kosh_card.dart';
import '../models/transaction_type.dart';
import '../viewmodel/transaction_viewmodel.dart';

/// Screen displaying the details of a single transaction.
class TransactionDetailsScreen extends ConsumerWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
  });

  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionViewModelProvider);
    
    // Find transaction
    final transaction = state.transactions.where((t) => t.id == transactionId).firstOrNull;

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMMM yyyy, hh:mm a');
    
    final isIncome = transaction.type == TransactionType.income;
    final typeColor = transaction.type.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              context.pushNamed(
                RouteConstants.addTransaction,
                queryParameters: {'id': transaction.id.toString()},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.danger),
            onPressed: () => _confirmDelete(context, ref, transaction.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Amount & Title Header
            KoshCard(
              showGlow: true,
              glowColor: typeColor,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: transaction.category.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      transaction.category.icon,
                      color: transaction.category.color,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    transaction.title,
                    style: AppTextStyles.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                    style: AppTextStyles.displayMedium.copyWith(color: typeColor),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      transaction.type.label,
                      style: AppTextStyles.captionBold.copyWith(color: typeColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Details List
            KoshCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDetailRow('Category', transaction.category.label, Icons.category_rounded),
                  const Divider(height: 1, color: AppColors.surfaceBorder),
                  _buildDetailRow('Date', dateFormat.format(transaction.date), Icons.calendar_today_rounded),
                  
                  if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                    const Divider(height: 1, color: AppColors.surfaceBorder),
                    _buildDetailRow('Notes', transaction.notes!, Icons.notes_rounded, isMultiline: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textTertiary, size: AppSpacing.iconMd),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyBold,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ref.read(transactionViewModelProvider.notifier).deleteTransaction(id);
      context.pop(); // Go back to list
    }
  }
}
