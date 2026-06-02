import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';

import '../../database/collections/transaction_collection.dart';
import '../../database/collections/goal_collection.dart';

import '../../features/transactions/models/transaction_category.dart';
import '../../features/transactions/models/transaction_type.dart';
import '../../features/goals/models/goal_category.dart';
import '../../features/goals/models/goal_priority.dart';

class BackupService {
  final Isar isar;

  BackupService(this.isar);

  // --- JSON Backup Export ---

  Future<String?> exportBackup() async {
    try {
      final transactions = await isar.transactionCollections.where().findAll();
      final goals = await isar.goalCollections.where().findAll();

      // Convert data to Maps
      final data = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'transactions': transactions.map((t) => {
          'title': t.title,
          'amount': t.amount,
          'type': t.type.name,
          'category': t.category.name,
          'date': t.date.toIso8601String(),
          'notes': t.notes,
        }).toList(),
        'goals': goals.map((g) => {
          'title': g.title,
          'targetAmount': g.targetAmount,
          'currentAmount': g.currentAmount,
          'deadline': g.deadline.toIso8601String(),
          'priority': g.priority.name,
          'category': g.category.name,
          'isCompleted': g.isCompleted,
        }).toList(),
      };

      final jsonString = jsonEncode(data);

      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Backup',
        fileName: 'kosh_backup_$formattedDate.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        return outputFile;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }

  // --- JSON Backup Import ---

  Future<bool> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString);

        if (data['version'] == null || data['version'] != 1) {
          throw Exception('Unsupported backup version.');
        }

        await isar.writeTxn(() async {
          // Clear current data
          await isar.transactionCollections.clear();
          await isar.goalCollections.clear();

          // Import Transactions
          if (data['transactions'] != null) {
            final txs = (data['transactions'] as List).map((t) => TransactionCollection()
              ..title = t['title']
              ..amount = t['amount']
              ..type = TransactionType.values.firstWhere((e) => e.name == t['type'])
              ..category = TransactionCategory.values.firstWhere((e) => e.name == t['category'])
              ..date = DateTime.parse(t['date'])
              ..notes = t['notes']
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now()
            ).toList();
            await isar.transactionCollections.putAll(txs);
          }

          // Import Goals
          if (data['goals'] != null) {
            final goalsList = (data['goals'] as List).map((g) => GoalCollection()
              ..title = g['title']
              ..targetAmount = g['targetAmount']
              ..currentAmount = g['currentAmount']
              ..deadline = DateTime.parse(g['deadline'])
              ..priority = GoalPriority.values.firstWhere((e) => e.name == g['priority'])
              ..category = GoalCategory.values.firstWhere((e) => e.name == g['category'])
              ..isCompleted = g['isCompleted']
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now()
            ).toList();
            await isar.goalCollections.putAll(goalsList);
          }
        });
        
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  // --- CSV Export ---

  Future<String?> exportTransactionsCsv() async {
    try {
      final transactions = await isar.transactionCollections.where().sortByDateDesc().findAll();

      List<List<dynamic>> rows = [];
      // Header
      rows.add(['Date', 'Title', 'Amount', 'Type', 'Category', 'Notes']);

      for (var t in transactions) {
        rows.add([
          DateFormat('yyyy-MM-dd HH:mm').format(t.date),
          t.title,
          t.amount,
          t.type.name,
          t.category.name,
          t.notes ?? '',
        ]);
      }

      String csvData = csv.encode(rows);

      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Export Transactions as CSV',
        fileName: 'kosh_transactions_$formattedDate.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csvData);
        return outputFile;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }
}
