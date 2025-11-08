import 'dart:io';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/activity_log.dart';

/// Export service for activity logs
/// Supports CSV, PDF, and text file formats
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
      buffer.writeln('Member Name,Checked In,Checked Out,Duration');
      
      // Data rows
      for (final activity in activities) {
        final memberName = activity.memberName;
        
        // Format check-in time
        String checkedIn = '--';
        if (activity.checkInTime != null) {
          checkedIn = DateFormat('yyyy-MM-dd HH:mm:ss').format(activity.checkInTime!);
        } else if (!activity.success) {
          checkedIn = 'Plan Expired';
        }
        
        // Format check-out time
        String checkedOut = '--';
        if (activity.checkOutTime != null) {
          checkedOut = DateFormat('yyyy-MM-dd HH:mm:ss').format(activity.checkOutTime!);
        } else if (!activity.success) {
          checkedOut = 'Access Denied';
        } else if (activity.checkInTime != null) {
          checkedOut = 'Active Session';
        }
        
        // Format duration
        String duration = '--';
        if (!activity.success) {
          duration = 'Denied';
        } else if (activity.checkInTime != null && activity.checkOutTime != null) {
          duration = activity.formattedDuration;
        } else if (activity.checkInTime != null) {
          duration = 'In Progress';
        }
        
        buffer.writeln(
          '"$memberName","$checkedIn","$checkedOut","$duration"',
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

  /// Export activity logs to PDF file
  Future<String?> exportToPDF(List<ActivityLog> activities) async {
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
      final filename = 'mitugym_activity_$timestamp.pdf';
      final file = File('${exportDir.path}/$filename');

      // Create PDF document
      final pdf = pw.Document();

      // Calculate statistics
      final successful = activities.where((a) => a.success).length;
      final failed = activities.where((a) => !a.success).length;
      final successRate = (successful / activities.length * 100).toStringAsFixed(1);

      // Add page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MituGym Scanner',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Activity Report',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.teal700, thickness: 2),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),

              // Report info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Generated: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total Activities: ${activities.length}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Statistics section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.teal200, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Statistics',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Successful', '$successful', PdfColors.green700),
                        _buildStatItem('Failed', '$failed', PdfColors.red700),
                        _buildStatItem('Success Rate', '$successRate%', PdfColors.blue700),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Activity table header
              pw.Text(
                'Activity Log',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              
              pw.SizedBox(height: 12),

              // Table
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.teal700,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(8),
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                },
                headers: ['Member Name', 'Checked In', 'Checked Out', 'Duration'],
                data: activities.map((activity) {
                  // Format check-in
                  String checkedIn = '--';
                  if (activity.checkInTime != null) {
                    checkedIn = DateFormat('yyyy-MM-dd HH:mm').format(activity.checkInTime!);
                  } else if (!activity.success) {
                    checkedIn = 'Plan Expired';
                  }
                  
                  // Format check-out
                  String checkedOut = '--';
                  if (activity.checkOutTime != null) {
                    checkedOut = DateFormat('yyyy-MM-dd HH:mm').format(activity.checkOutTime!);
                  } else if (!activity.success) {
                    checkedOut = 'Access Denied';
                  } else if (activity.checkInTime != null) {
                    checkedOut = 'Active Session';
                  }
                  
                  // Format duration
                  String duration = '--';
                  if (!activity.success) {
                    duration = 'Denied';
                  } else if (activity.checkInTime != null && activity.checkOutTime != null) {
                    duration = activity.formattedDuration;
                  } else if (activity.checkInTime != null) {
                    duration = 'In Progress';
                  }
                  
                  return [
                    activity.memberName,
                    checkedIn,
                    checkedOut,
                    duration,
                  ];
                }).toList(),
              ),
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            );
          },
        ),
      );

      // Save to file
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);
      
      _logger.i('Exported ${activities.length} activities to PDF: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('Failed to export PDF: $e');
      return null;
    }
  }

  /// Helper to build stat items for PDF
  pw.Widget _buildStatItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
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
      buffer.writeln('-'.padRight(80, '-'));
      buffer.writeln('Member Name | Checked In | Checked Out | Duration');
      buffer.writeln('-'.padRight(80, '-'));
      
      for (final activity in activities) {
        // Format check-in
        String checkedIn = '--';
        if (activity.checkInTime != null) {
          checkedIn = DateFormat('yyyy-MM-dd HH:mm').format(activity.checkInTime!);
        } else if (!activity.success) {
          checkedIn = 'Plan Expired';
        }
        
        // Format check-out
        String checkedOut = '--';
        if (activity.checkOutTime != null) {
          checkedOut = DateFormat('yyyy-MM-dd HH:mm').format(activity.checkOutTime!);
        } else if (!activity.success) {
          checkedOut = 'Access Denied';
        } else if (activity.checkInTime != null) {
          checkedOut = 'Active Session';
        }
        
        // Format duration
        String duration = '--';
        if (!activity.success) {
          duration = 'Denied';
        } else if (activity.checkInTime != null && activity.checkOutTime != null) {
          duration = activity.formattedDuration;
        } else if (activity.checkInTime != null) {
          duration = 'In Progress';
        }
        
        buffer.writeln(
          '${activity.memberName.padRight(20)} | ${checkedIn.padRight(16)} | ${checkedOut.padRight(16)} | $duration',
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

