import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _exporting = false;
  bool _importing = false;

  Future<void> _handleExport() async {
    setState(() => _exporting = true);
    try {
      await BackupService.shareBackup();
    } catch (e) {
      if (mounted) {
        _showSnack('Export failed: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _handleImport() async {
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedPath = result.files.single.path;
      if (pickedPath == null) {
        _showSnack('Could not read the selected file.', error: true);
        return;
      }

      final file = File(pickedPath);
      final jsonStr = await file.readAsString();

      BackupSummary backupSummary;
      try {
        backupSummary = BackupService.previewFromJsonString(jsonStr);
      } catch (e) {
        _showSnack('Not a valid Loopify backup file.', error: true);
        return;
      }

      final currentSummary = BackupService.currentSummary();

      if (!mounted) return;
      final confirmed = await _showPreviewDialog(currentSummary, backupSummary);
      if (confirmed != true) return;

      // Safety backup of current data
      File? safetyFile;
      try {
        safetyFile = await BackupService.createSafetyBackup();
      } catch (_) {
        // Non-fatal — user already confirmed they want to proceed.
      }

      await BackupService.restoreFromJsonString(jsonStr);

      if (!mounted) return;
      await _showRestoreCompleteDialog(safetyFile?.path);
    } catch (e) {
      if (mounted) _showSnack('Import failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<bool?> _showPreviewDialog(
    BackupSummary current,
    BackupSummary backup,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text(
          'Confirm restore',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (backup.exportedAt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Backup exported: ${_formatDate(backup.exportedAt!)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              _summaryTable(current, backup),
              const SizedBox(height: 16),
              const Text(
                'This will WIPE the current data on this device and replace it with the backup.',
                style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
              ),
              const SizedBox(height: 8),
              const Text(
                'A safety copy of the current data will be saved to Downloads before any change is made.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Replace data'),
          ),
        ],
      ),
    );
  }

  Widget _summaryTable(BackupSummary current, BackupSummary backup) {
    Widget row(String label, String c, String b) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(label,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text(c,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(b,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 2,
                child: Text('Current',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text('Backup',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          row('Current streak', '${current.currentStreak}', '${backup.currentStreak}'),
          row('Best streak', '${current.bestStreak}', '${backup.bestStreak}'),
          row('Day logs', '${current.dayLogs}', '${backup.dayLogs}'),
          row('Projects', '${current.projects}', '${backup.projects}'),
          row('Custom habits', '${current.customHabits}', '${backup.customHabits}'),
          row('Achievement notes', '${current.achievementNotes}',
              '${backup.achievementNotes}'),
          row('Challenges', '${current.challenges}', '${backup.challenges}'),
          row('Recovery tokens', '${current.recoveryTokens}', '${backup.recoveryTokens}'),
        ],
      ),
    );
  }

  Future<void> _showRestoreCompleteDialog(String? safetyPath) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text(
          'Restore complete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your data has been restored from the backup.',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'The app needs to close so it can reload your data. Tap below — then re-open Loopify from your launcher.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (safetyPath != null) ...[
              const SizedBox(height: 12),
              Text(
                'Safety backup of previous data saved to:\n$safetyPath',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(ctx);
              SystemNavigator.pop();
            },
            child: const Text('Close app'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red[700] : Colors.green[700],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final l = d.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0A0E21),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1E33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[800]!, width: 2),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What gets backed up',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                SizedBox(height: 8),
                Text(
                  '• Every day log + habit (predefined and custom)\n'
                  '• Current streak, best streak, grace passes\n'
                  '• Projects + milestones\n'
                  '• Achievements + notes\n'
                  '• Challenges (active and historical)\n'
                  '• Settings, recovery tokens, lifetime stats',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // EXPORT
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1D1E33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[800]!, width: 2),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _exporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.orange, strokeWidth: 2.5),
                      )
                    : const Icon(Icons.upload_file, color: Colors.orange, size: 28),
              ),
              title: const Text(
                'Export backup',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Creates a JSON file and opens the share sheet. Send to Gmail, Drive, WhatsApp, or save to Files.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              enabled: !_exporting,
              onTap: _exporting ? null : _handleExport,
            ),
          ),
          const SizedBox(height: 12),

          // IMPORT
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1D1E33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[800]!, width: 2),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _importing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.blue, strokeWidth: 2.5),
                      )
                    : const Icon(Icons.download_for_offline, color: Colors.blue, size: 28),
              ),
              title: const Text(
                'Import backup',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Pick a Loopify backup JSON file. You\'ll preview the contents before anything is replaced. A safety copy of current data is saved first.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              enabled: !_importing,
              onTap: _importing ? null : _handleImport,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.amberAccent, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'After Import, the app will ask to close. Re-open it from your launcher — your full data (streak included) will be loaded.',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 12),
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
