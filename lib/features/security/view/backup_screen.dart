import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/backup_service.dart';
import '../../../providers/repository_providers.dart';
import '../../../shared/cards/kosh_card.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isLoading = false;

  /// Unwraps [AppException] so users see the message, not the type and code.
  String _describeError(Object error) =>
      error is AppException ? error.message : error.toString();

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_describeError(error)),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    try {
      final path = await ref.read(backupServiceProvider).exportBackup();
      if (path != null) _showMessage('Backup saved to: $path');
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importBackup() async {
    // Restoring wipes every local record, so it needs an explicit yes first.
    final confirmed = await _confirmRestore();
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(backupServiceProvider).importBackup();
      if (result != null) await _showRestoreSummary(result);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _confirmRestore() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Restore from backup?'),
        content: const Text(
          'This replaces all transactions, goals, contributions and vision '
          'items currently on this device with the contents of the backup '
          'file. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Choose file'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreSummary(BackupRestoreResult result) {
    if (!mounted) return Future.value();

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Backup restored'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${result.transactions} transactions\n'
              '${result.goals} goals\n'
              '${result.contributions} contributions\n'
              '${result.visionItems} vision items\n'
              '${result.achievementsUnlocked} achievements',
              style: const TextStyle(color: Colors.white70),
            ),
            if (result.hasSkipped) ...[
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Not restored',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...result.skipped.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $note',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    setState(() => _isLoading = true);
    try {
      final path =
          await ref.read(backupServiceProvider).exportTransactionsCsv();
      if (path != null) _showMessage('CSV saved to: $path');
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                KoshCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cloud_download_outlined, color: AppColors.primary),
                          SizedBox(width: AppSpacing.sm),
                          Text('JSON Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Export all your data into a single JSON file. You can restore this file later if you change devices.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _exportBackup,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Export JSON'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _importBackup,
                              icon: const Icon(Icons.file_download),
                              label: const Text('Restore'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                KoshCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.table_chart_outlined, color: AppColors.success),
                          SizedBox(width: AppSpacing.sm),
                          Text('CSV Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Export your transactions as a spreadsheet for Excel or your accountant.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _exportCsv,
                          icon: const Icon(Icons.file_present),
                          label: const Text('Export Transactions CSV'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: AppColors.success),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
