import 'dart:io';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../models/activity_log.dart';

/// Export service for activity logs
/// Supports CSV and text file formats
class ExportService {
  final Logger _logger = Logger();

  /// Export activity logs to CSV file
  Future<String?> exportToCSV(List<ActivityLog> activities) async {
    try {
      if (activities.isEmpty) {
        _logger.w('No activities to export');
        return null;
      }

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/mitugym_exports');
      
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Create filename with timestamp
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final filename = 'mitugym_activity_$timestamp.csv';
      final file = File('${exportDir.path}/$filename');

      // Create CSV content
      final buffer = StringBuffer();
      
      // Header
      buffer.writeln('Member Name,Action,Date,Time,Status');
      
      // Data rows
      for (final activity in activities) {
        final date = DateFormat('yyyy-MM-dd').format(activity.time);
        final time = DateFormat('HH:mm:ss').format(activity.time);
        final status = activity.success ? 'Success' : 'Failed';
        
        buffer.writeln(
          '"${activity.memberName}","${activity.action}","$date","$time","$status"',
        );
      }

      // Write to file
      await file.writeAsString(buffer.toString());
      
      _logger.i('Exported ${activities.length} activities to: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('Failed to export CSV: $e');
      return null;
    }
  }

  /// Export activity logs to formatted text file
  Future<String?> exportToText(List<ActivityLog> activities) async {
    try {
      if (activities.isEmpty) {
        _logger.w('No activities to export');
        return null;
      }

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/mitugym_exports');
      
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Create filename with timestamp
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final filename = 'mitugym_activity_$timestamp.txt';
      final file = File('${exportDir.path}/$filename');

      // Create formatted content
      final buffer = StringBuffer();
      
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln('MituGym Scanner - Activity Report');
      buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
      buffer.writeln('Total Activities: ${activities.length}');
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln();

      // Statistics
      final successful = activities.where((a) => a.success).length;
      final failed = activities.where((a) => a.success == false).length;
      
      buffer.writeln('STATISTICS');
      buffer.writeln('-'.padRight(60, '-'));
      buffer.writeln('Successful: $successful');
      buffer.writeln('Failed: $failed');
      buffer.writeln('Success Rate: ${(successful / activities.length * 100).toStringAsFixed(1)}%');
      buffer.writeln();

      // Activity list
      buffer.writeln('ACTIVITY LOG');
      buffer.writeln('-'.padRight(60, '-'));
      
      for (final activity in activities) {
        final status = activity.success ? '✓' : '✗';
        buffer.writeln(
          '$status ${activity.formattedDateTime} | ${activity.memberName} | ${activity.action}',
        );
      }

      buffer.writeln();
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln('End of Report');

      // Write to file
      await file.writeAsString(buffer.toString());
      
      _logger.i('Exported ${activities.length} activities to: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('Failed to export text: $e');
      return null;
    }
  }

  /// Get list of all export files
  Future<List<File>> getExportFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/mitugym_exports');
      
      if (!await exportDir.exists()) {
        return [];
      }

      final files = await exportDir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
      
      // Sort by date (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return files;
    } catch (e) {
      _logger.e('Failed to get export files: $e');
      return [];
    }
  }

  /// Delete an export file
  Future<bool> deleteExportFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.i('Deleted export file: $path');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to delete export file: $e');
      return false;
    }
  }

  /// Open export directory in file explorer
  Future<String?> getExportDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/mitugym_exports');
      
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      
      return exportDir.path;
    } catch (e) {
      _logger.e('Failed to get export directory: $e');
      return null;
    }
  }
}

