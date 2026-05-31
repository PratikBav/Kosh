import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/widgets/empty_state.dart';

/// Transactions placeholder screen.
///
/// Shows the empty state widget, validating the shared widget system.
class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: EmptyState(
        icon: Icons.swap_horiz_rounded,
        title: 'No Transactions Yet',
        description: 'Your income and expenses will appear here.\nStart tracking your finances!',
        actionLabel: 'Add Transaction',
        onAction: () {},
      ).animate().fadeIn(duration: 500.ms),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
