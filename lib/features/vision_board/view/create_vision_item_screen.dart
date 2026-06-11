import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../database/collections/vision_item_collection.dart';
import '../../../shared/widgets/kosh_textfield.dart';
import '../../goals/viewmodel/goals_viewmodel.dart';
import '../viewmodel/vision_board_viewmodel.dart';

class CreateVisionItemScreen extends ConsumerStatefulWidget {
  const CreateVisionItemScreen({super.key});

  @override
  ConsumerState<CreateVisionItemScreen> createState() => _CreateVisionItemScreenState();
}

class _CreateVisionItemScreenState extends ConsumerState<CreateVisionItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quoteController = TextEditingController();
  
  VisionCategory _selectedCategory = VisionCategory.other;
  int? _selectedGoalId;
  String? _imagePath;
  
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final viewModel = ref.read(visionBoardViewModelProvider.notifier);
    
    await viewModel.addVisionItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      originalImagePath: _imagePath,
      quote: _quoteController.text.trim(),
      goalId: _selectedGoalId,
      category: _selectedCategory,
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsViewModelProvider);
    final activeGoals = goalsState.goals.where((g) => !g.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Add to Vision Board'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    image: _imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48, color: AppColors.primary),
                            SizedBox(height: AppSpacing.sm),
                            Text('Tap to add an image', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              KoshTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'E.g., Dream Home, Japan Trip',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Category Dropdown
              DropdownButtonFormField<VisionCategory>(
                initialValue: _selectedCategory,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.category, color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: VisionCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Linked Goal Dropdown
              if (activeGoals.isNotEmpty) ...[
                DropdownButtonFormField<int?>(
                  initialValue: _selectedGoalId,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Link to a Goal (Optional)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.flag, color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...activeGoals.map((goal) {
                      return DropdownMenuItem<int?>(
                        value: goal.id,
                        child: Text(goal.title),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGoalId = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Quote
              KoshTextField(
                controller: _quoteController,
                label: 'Motivational Quote',
                hint: 'E.g., Small savings become big dreams.',
                prefixIcon: Icons.format_quote,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              KoshTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Why does this matter to you?',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save to Vision Board',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
