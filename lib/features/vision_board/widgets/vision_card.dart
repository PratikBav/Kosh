import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/route_constants.dart';
import '../../../database/collections/vision_item_collection.dart';
import '../../goals/viewmodel/goals_viewmodel.dart';

class VisionCard extends ConsumerWidget {
  final VisionItemCollection vision;
  
  const VisionCard({super.key, required this.vision});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If goal is linked, fetch it from GoalsViewModel
    final goalsState = ref.watch(goalsViewModelProvider);
    final linkedGoal = vision.goalId != null 
        ? goalsState.goals.where((g) => g.id == vision.goalId).firstOrNull 
        : null;

    double progress = 0.0;
    if (linkedGoal != null && linkedGoal.targetAmount > 0) {
      progress = (linkedGoal.currentAmount / linkedGoal.targetAmount).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteConstants.visionItemDetails,
          pathParameters: {'id': vision.id.toString()},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (vision.imagePath != null && File(vision.imagePath!).existsSync())
                    Image.file(
                      File(vision.imagePath!),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: AppColors.surfaceBorder,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: AppColors.textTertiary, size: 40),
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
                          AppColors.background.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  
                  // Pin Icon
                  if (vision.isPinned)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.push_pin, color: AppColors.primary, size: 16),
                      ),
                    ),
                  
                  // Quote Overlay (if no goal)
                  if (vision.quote != null && linkedGoal == null)
                    Positioned(
                      bottom: 8,
                      left: 12,
                      right: 12,
                      child: Text(
                        '"${vision.quote}"',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            
            // Details Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vision.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (linkedGoal != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Complete',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceBorder,
                        color: progress >= 1.0 ? AppColors.success : AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ] else if (vision.description != null && vision.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vision.description!,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
