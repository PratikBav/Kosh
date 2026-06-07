import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/route_constants.dart';
import '../viewmodel/vision_board_viewmodel.dart';
import '../widgets/vision_card.dart';

class VisionBoardScreen extends ConsumerStatefulWidget {
  const VisionBoardScreen({super.key});

  @override
  ConsumerState<VisionBoardScreen> createState() => _VisionBoardScreenState();
}

class _VisionBoardScreenState extends ConsumerState<VisionBoardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visionBoardViewModelProvider);
    final viewModel = ref.read(visionBoardViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Vision Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: () {
              context.pushNamed(RouteConstants.createVisionItem);
            },
          ),
        ],
      ),
      body: state.isLoading && state.allItems.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search dreams...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textTertiary),
                                onPressed: () {
                                  _searchController.clear();
                                  viewModel.setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: viewModel.setSearchQuery,
                    ),
                  ),
                ),

                // Error Message
                if (state.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: AppColors.danger.withValues(alpha: 0.1),
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ),
                  ),

                // Empty State
                if (state.filteredItems.isEmpty && !state.isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 64,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'Your dreams belong here.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Create your first vision board item.',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.pushNamed(RouteConstants.createVisionItem);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Dream'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Pinned Dreams
                  if (state.pinnedItems.isNotEmpty && state.searchQuery.isEmpty) ...[
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                        child: Text(
                          'Pinned Dreams',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = state.pinnedItems[index];
                            return VisionCard(vision: item);
                          },
                          childCount: state.pinnedItems.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
                  ],

                  // All Dreams Grid
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                      child: Text(
                        'Inspiration Grid',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = state.filteredItems[index];
                          return VisionCard(vision: item);
                        },
                        childCount: state.filteredItems.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                ],
              ],
            ),
    );
  }
}
