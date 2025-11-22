import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/activity_log.dart';
import '../models/member_data.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';

/// Export service for activity logs
/// Supports CSV, PDF, and text file formats
class ExportService {
  final Logger _logger = Logger();
  pw.Font? _cachedFont;
  pw.Font? _cachedBoldFont;

  /// Load a Unicode-compatible font for PDF generation from bundled assets
  Future<pw.Font> _loadFont() async {
    if (_cachedFont != null) return _cachedFont!;
    
    try {
      // Load Roboto font from bundled assets (supports Unicode including Romanian characters)
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      _cachedFont = pw.Font.ttf(fontData);
      _logger.i('Successfully loaded custom font from assets');
      return _cachedFont!;
    } catch (e) {
      _logger.e('Failed to load custom font from assets: $e');
      rethrow;
    }
  }

  /// Load a bold Unicode-compatible font for PDF generation from bundled assets
  Future<pw.Font> _loadBoldFont() async {
    if (_cachedBoldFont != null) return _cachedBoldFont!;
    
    try {
      // Load Roboto Bold font from bundled assets
      final fontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      _cachedBoldFont = pw.Font.ttf(fontData);
      _logger.i('Successfully loaded custom bold font from assets');
      return _cachedBoldFont!;
    } catch (e) {
      _logger.e('Failed to load custom bold font from assets: $e');
      rethrow;
    }
  }

  /// Export activity logs to CSV file
  Future<String?> exportToCSV(List<ActivityLog> activities, AppLocalizations l10n, {String? customPath}) async {
    try {
      if (activities.isEmpty) {
        _logger.w('No activities to export');
        return null;
      }

      // Get export directory - use custom path if provided, otherwise default
      Directory exportDir;
      if (customPath != null && customPath.isNotEmpty) {
        exportDir = Directory(customPath);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        exportDir = Directory('${directory.path}/mitugym_exports');
      }
      
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
      buffer.writeln('${l10n.exportMemberName},${l10n.exportCheckedIn},${l10n.exportCheckedOut},${l10n.exportDuration}');
      
      // Data rows
      for (final activity in activities) {
        final memberName = activity.memberName;
        
        // Format check-in time
        String checkedIn = '--';
        if (activity.checkInTime != null) {
          checkedIn = DateFormat('yyyy-MM-dd HH:mm:ss').format(activity.checkInTime!);
        } else if (!activity.success) {
          checkedIn = l10n.exportPlanExpired;
        }
        
        // Format check-out time
        String checkedOut = '--';
        if (activity.checkOutTime != null) {
          checkedOut = DateFormat('yyyy-MM-dd HH:mm:ss').format(activity.checkOutTime!);
        } else if (!activity.success) {
          checkedOut = l10n.exportAccessDenied;
        } else if (activity.checkInTime != null) {
          checkedOut = l10n.exportActiveSession;
        }
        
        // Format duration
        String duration = '--';
        if (!activity.success) {
          duration = l10n.exportDenied;
        } else if (activity.checkInTime != null && activity.checkOutTime != null) {
          duration = activity.formattedDuration;
        } else if (activity.checkInTime != null) {
          duration = l10n.exportInProgress;
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
  Future<String?> exportToPDF(List<ActivityLog> activities, AppLocalizations l10n, {String? customPath}) async {
    try {
      if (activities.isEmpty) {
        _logger.w('No activities to export');
        return null;
      }

      // Get export directory - use custom path if provided, otherwise default
      Directory exportDir;
      if (customPath != null && customPath.isNotEmpty) {
        exportDir = Directory(customPath);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        exportDir = Directory('${directory.path}/mitugym_exports');
      }
      
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

      // Try to load custom font for Unicode support, but continue without it if it fails
      pw.Font? customFont;
      pw.Font? customBoldFont;
      try {
        customFont = await _loadFont();
        customBoldFont = await _loadBoldFont();
        _logger.i('Using custom fonts for Unicode support');
      } catch (e) {
        _logger.w('Custom fonts not available, using default fonts (some characters may not display correctly): $e');
      }

      // Add page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          theme: customFont != null && customBoldFont != null
              ? pw.ThemeData.withFont(
                  base: customFont,
                  bold: customBoldFont,
                )
              : null,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      AppConstants.appName,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      l10n.exportActivityReport,
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
                        '${l10n.exportGenerated}: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        '${l10n.exportTime}: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        '${l10n.exportTotalActivities}: ${activities.length}',
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
                      l10n.exportStatistics,
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
                        _buildStatItem(l10n.exportSuccessful, '$successful', PdfColors.green700),
                        _buildStatItem(l10n.exportFailedLabel, '$failed', PdfColors.red700),
                        _buildStatItem(l10n.exportSuccessRate, '$successRate%', PdfColors.blue700),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Activity table header
              pw.Text(
                l10n.exportActivityLog,
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
                headers: [l10n.exportMemberName, l10n.exportCheckedIn, l10n.exportCheckedOut, l10n.exportDuration],
                data: activities.map((activity) {
                  // Format check-in
                  String checkedIn = '--';
                  if (activity.checkInTime != null) {
                    checkedIn = DateFormat('yyyy-MM-dd HH:mm').format(activity.checkInTime!);
                  } else if (!activity.success) {
                    checkedIn = l10n.exportPlanExpired;
                  }
                  
                  // Format check-out
                  String checkedOut = '--';
                  if (activity.checkOutTime != null) {
                    checkedOut = DateFormat('yyyy-MM-dd HH:mm').format(activity.checkOutTime!);
                  } else if (!activity.success) {
                    checkedOut = l10n.exportAccessDenied;
                  } else if (activity.checkInTime != null) {
                    checkedOut = l10n.exportActiveSession;
                  }
                  
                  // Format duration
                  String duration = '--';
                  if (!activity.success) {
                    duration = l10n.exportDenied;
                  } else if (activity.checkInTime != null && activity.checkOutTime != null) {
                    duration = activity.formattedDuration;
                  } else if (activity.checkInTime != null) {
                    duration = l10n.exportInProgress;
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
                '${l10n.exportPage} ${context.pageNumber} ${l10n.exportOf} ${context.pagesCount}',
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
  Future<String?> exportToText(List<ActivityLog> activities, AppLocalizations l10n, {String? customPath}) async{
    try {
      if (activities.isEmpty) {
        _logger.w('No activities to export');
        return null;
      }

      // Get export directory - use custom path if provided, otherwise default
      Directory exportDir;
      if (customPath != null && customPath.isNotEmpty) {
        exportDir = Directory(customPath);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        exportDir = Directory('${directory.path}/mitugym_exports');
      }
      
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
      buffer.writeln('${AppConstants.appName} - ${l10n.exportActivityReport}');
      buffer.writeln('${l10n.exportGenerated}: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
      buffer.writeln('${l10n.exportTotalActivities}: ${activities.length}');
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln();

      // Statistics
      final successful = activities.where((a) => a.success).length;
      final failed = activities.where((a) => a.success == false).length;
      
      buffer.writeln(l10n.exportStatistics.toUpperCase());
      buffer.writeln('-'.padRight(60, '-'));
      buffer.writeln('${l10n.exportSuccessful}: $successful');
      buffer.writeln('${l10n.exportFailedLabel}: $failed');
      buffer.writeln('${l10n.exportSuccessRate}: ${(successful / activities.length * 100).toStringAsFixed(1)}%');
      buffer.writeln();

      // Activity list
      buffer.writeln(l10n.exportActivityLog.toUpperCase());
      buffer.writeln('-'.padRight(80, '-'));
      buffer.writeln('${l10n.exportMemberName} | ${l10n.exportCheckedIn} | ${l10n.exportCheckedOut} | ${l10n.exportDuration}');
      buffer.writeln('-'.padRight(80, '-'));
      
      for (final activity in activities) {
        // Format check-in
        String checkedIn = '--';
        if (activity.checkInTime != null) {
          checkedIn = DateFormat('yyyy-MM-dd HH:mm').format(activity.checkInTime!);
        } else if (!activity.success) {
          checkedIn = l10n.exportPlanExpired;
        }
        
        // Format check-out
        String checkedOut = '--';
        if (activity.checkOutTime != null) {
          checkedOut = DateFormat('yyyy-MM-dd HH:mm').format(activity.checkOutTime!);
        } else if (!activity.success) {
          checkedOut = l10n.exportAccessDenied;
        } else if (activity.checkInTime != null) {
          checkedOut = l10n.exportActiveSession;
        }
        
        // Format duration
        String duration = '--';
        if (!activity.success) {
          duration = l10n.exportDenied;
        } else if (activity.checkInTime != null && activity.checkOutTime != null) {
          duration = activity.formattedDuration;
        } else if (activity.checkInTime != null) {
          duration = l10n.exportInProgress;
        }
        
        buffer.writeln(
          '${activity.memberName.padRight(20)} | ${checkedIn.padRight(16)} | ${checkedOut.padRight(16)} | $duration',
        );
      }

      buffer.writeln();
      buffer.writeln('='.padRight(60, '='));
      buffer.writeln(l10n.exportEndOfReport);

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

  // ============================================================================
  // Members Export Methods
  // ============================================================================

  /// Export members list to CSV file
  Future<String?> exportMembersToCSV(List<MemberData> members, AppLocalizations l10n, {String? customPath}) async {
    try {
      if (members.isEmpty) {
        _logger.w('No members to export');
        return null;
      }

      // Get export directory - use custom path if provided, otherwise default
      Directory exportDir;
      if (customPath != null && customPath.isNotEmpty) {
        exportDir = Directory(customPath);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        exportDir = Directory('${directory.path}/mitugym_exports');
      }
      
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Create filename with timestamp
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final filename = 'mitugym_members_$timestamp.csv';
      final file = File('${exportDir.path}/$filename');

      // Create CSV content
      final buffer = StringBuffer();
      
      // Header
      buffer.writeln('${l10n.exportMemberId},${l10n.exportMemberName},${l10n.exportPlan},${l10n.exportStatus},${l10n.exportExpires},${l10n.exportEmail},${l10n.exportPhone},${l10n.exportGender},${l10n.exportDateOfBirth},${l10n.exportAddress}');
      
      // Data rows
      for (final member in members) {
        buffer.writeln(
          '"${member.memberId}",'
          '"${member.memberName}",'
          '"${member.planName}",'
          '"${member.membershipStatus}",'
          '"${member.formattedExpiryDate}",'
          '"${member.email ?? '--'}",'
          '"${member.phone ?? '--'}",'
          '"${member.gender ?? '--'}",'
          '"${member.formattedBirthDate ?? '--'}",'
          '"${member.fullAddress ?? '--'}"',
        );
      }

      // Write to file
      await file.writeAsString(buffer.toString());
      
      _logger.i('Exported ${members.length} members to: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('Failed to export members CSV: $e');
      return null;
    }
  }

  /// Export members list to PDF file
  Future<String?> exportMembersToPDF(List<MemberData> members, AppLocalizations l10n, {String? customPath}) async {
    try {
      if (members.isEmpty) {
        _logger.w('No members to export');
        return null;
      }

      // Get export directory - use custom path if provided, otherwise default
      Directory exportDir;
      if (customPath != null && customPath.isNotEmpty) {
        exportDir = Directory(customPath);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        exportDir = Directory('${directory.path}/mitugym_exports');
      }
      
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Create filename with timestamp
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final filename = 'mitugym_members_$timestamp.pdf';
      final file = File('${exportDir.path}/$filename');

      // Create PDF document
      final pdf = pw.Document();

      // Calculate statistics
      final activeMembers = members.where((m) => m.isActive).length;
      final inactiveMembers = members.length - activeMembers;

      // Try to load custom font for Unicode support, but continue without it if it fails
      pw.Font? customFont;
      pw.Font? customBoldFont;
      try {
        customFont = await _loadFont();
        customBoldFont = await _loadBoldFont();
        _logger.i('Using custom fonts for Unicode support');
      } catch (e) {
        _logger.w('Custom fonts not available, using default fonts (some characters may not display correctly): $e');
      }

      // Add page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape, // Landscape for more columns
          margin: const pw.EdgeInsets.all(40),
          theme: customFont != null && customBoldFont != null
              ? pw.ThemeData.withFont(
                  base: customFont,
                  bold: customBoldFont,
                )
              : null,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      AppConstants.appName,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal700,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      l10n.exportMembersList,
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
                        '${l10n.exportTotalMembers}: ${members.length}',
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
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(l10n.exportTotalMembers, '${members.length}', PdfColors.blue700),
                    _buildStatItem(l10n.exportActive, '$activeMembers', PdfColors.green700),
                    _buildStatItem(l10n.exportInactive, '$inactiveMembers', PdfColors.red700),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Members table header
              pw.Text(
                l10n.exportMembersDirectory,
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
                  fontSize: 9,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.teal700,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(6),
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.centerLeft,
                },
                headers: [l10n.exportName, l10n.exportPlan, l10n.exportStatus, l10n.exportExpires, l10n.exportContact, l10n.exportEmail],
                data: members.map((member) {
                  return [
                    member.memberName,
                    member.planName,
                    member.membershipStatus,
                    member.formattedExpiryDate,
                    member.phone ?? '--',
                    member.email ?? '--',
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
                '${l10n.exportPage} ${context.pageNumber} ${l10n.exportOf} ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            );
          },
        ),
      );

      // Save to file
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);
      
      _logger.i('Exported ${members.length} members to PDF: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('Failed to export members PDF: $e');
      return null;
    }
  }

  /// Export members list to formatted text file
  Future<String?> exportMembersToText(List<MemberData> members, AppLocalizations l10n, {String? customPath}) async {
    try {
      if (members.isEmpty) {
        _logger.w('No members to export');
        return null;
      }

      // Get export directory - use custom path if provided, otherwise default
      Directory exportDir;
      if (customPath != null && customPath.isNotEmpty) {
        exportDir = Directory(customPath);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        exportDir = Directory('${directory.path}/mitugym_exports');
      }
      
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Create filename with timestamp
      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final filename = 'mitugym_members_$timestamp.txt';
      final file = File('${exportDir.path}/$filename');

      // Create formatted content
      final buffer = StringBuffer();
      
      buffer.writeln('='.padRight(80, '='));
      buffer.writeln('${AppConstants.appName} - ${l10n.exportMembersList}');
      buffer.writeln('${l10n.exportGenerated}: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
      buffer.writeln('${l10n.exportTotalMembers}: ${members.length}');
      buffer.writeln('='.padRight(80, '='));
      buffer.writeln();

      // Statistics
      final activeMembers = members.where((m) => m.isActive).length;
      final inactiveMembers = members.length - activeMembers;
      
      buffer.writeln(l10n.exportStatistics.toUpperCase());
      buffer.writeln('-'.padRight(80, '-'));
      buffer.writeln('${l10n.exportTotalMembers}: ${members.length}');
      buffer.writeln('${l10n.exportActive}: $activeMembers');
      buffer.writeln('${l10n.exportInactive}: $inactiveMembers');
      buffer.writeln();

      // Members list
      buffer.writeln(l10n.exportMembersDirectory.toUpperCase());
      buffer.writeln('-'.padRight(100, '-'));
      buffer.writeln('${l10n.exportName} | ${l10n.exportPlan} | ${l10n.exportStatus} | ${l10n.exportExpires} | ${l10n.exportContact}');
      buffer.writeln('-'.padRight(100, '-'));
      
      for (final member in members) {
        buffer.writeln(
          '${member.memberName.padRight(25)} | '
          '${member.planName.padRight(20)} | '
          '${member.membershipStatus.padRight(10)} | '
          '${member.formattedExpiryDate.padRight(12)} | '
          '${(member.phone ?? '--').padRight(15)}',
        );
      }

      buffer.writeln();
      buffer.writeln('='.padRight(80, '='));
      buffer.writeln('End of Report');

      // Write to file
      await file.writeAsString(buffer.toString());
      
      _logger.i('Exported ${members.length} members to: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('Failed to export members text: $e');
      return null;
    }
  }
}

