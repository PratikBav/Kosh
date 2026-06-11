import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../goals/viewmodel/goals_viewmodel.dart';
import '../viewmodel/vision_board_viewmodel.dart';
import '../widgets/quote_card.dart';

class VisionItemDetailScreen extends ConsumerWidget {
  final int itemId;

  const VisionItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visionBoardViewModelProvider);
    final viewModel = ref.read(visionBoardViewModelProvider.notifier);
    
    final item = state.allItems.where((i) => i.id == itemId).firstOrNull;

    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: const Center(
          child: Text('Dream not found', style: TextStyle(color: AppColors.textPrimary)),
        ),
      );
    }

    // Check if goal linked
    final goalsState = ref.watch(goalsViewModelProvider);
    final linkedGoal = item.goalId != null 
        ? goalsState.goals.where((g) => g.id == item.goalId).firstOrNull 
        : null;

    double progress = 0.0;
    if (linkedGoal != null && linkedGoal.targetAmount > 0) {
      progress = (linkedGoal.currentAmount / linkedGoal.targetAmount).clamp(0.0, 1.0);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imagePath != null && File(item.imagePath!).existsSync())
                    Image.file(
                      File(item.imagePath!),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: AppColors.surfaceBorder,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: AppColors.textTertiary, size: 64),
                      ),
                    ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: item.isPinned ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: () {
                  viewModel.togglePin(item);
                  if (!item.isPinned && state.error != null) { // Trying to pin but full
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error!)),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('Delete Dream', style: TextStyle(color: AppColors.textPrimary)),
                      content: const Text('Are you sure you want to delete this vision board item?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await viewModel.deleteVisionItem(item);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item.category.label,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Goal Progress (if linked)
                  if (linkedGoal != null) ...[
                    const Text(
                      'Linked Goal Progress',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  linkedGoal.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.background,
                            color: progress >= 1.0 ? AppColors.success : AppColors.primary,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Quote
                  if (item.quote != null && item.quote!.isNotEmpty) ...[
                    QuoteCard(quote: item.quote!),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Description
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const Text(
                      'Why it matters',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
