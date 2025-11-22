import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';

/// Premium License Page with custom styling
class PremiumLicensePage extends StatefulWidget {
  const PremiumLicensePage({
    super.key,
  });

  @override
  State<PremiumLicensePage> createState() => _PremiumLicensePageState();
}

class _PremiumLicensePageState extends State<PremiumLicensePage> {
  final List<LicenseEntry> _licenses = <LicenseEntry>[];
  bool _loaded = false;
  String? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    await for (final license in LicenseRegistry.licenses) {
      if (!mounted) {
        return;
      }
      setState(() {
        _licenses.add(license);
      });
    }
    setState(() {
      _loaded = true;
    });
  }

  // Group licenses by package
  Map<String, List<LicenseEntry>> get _groupedLicenses {
    final Map<String, List<LicenseEntry>> grouped = {};
    for (final license in _licenses) {
      for (final package in license.packages) {
        grouped.putIfAbsent(package, () => []).add(license);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sortedPackages = _groupedLicenses.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Premium Header
          _buildHeader(context, l10n, sortedPackages.length),
          
          // Content
          Expanded(
            child: Row(
              children: [
                // Sidebar - Package List
                _buildPackageList(sortedPackages),
                
                // Main Content - License Details
                Expanded(
                  child: _buildLicenseContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build premium header
  Widget _buildHeader(BuildContext context, AppLocalizations l10n, int packageCount) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.background,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              // Back button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        LucideIcons.arrowLeft,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // App icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
              
              const SizedBox(width: 16),
              
              // Title and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.aboutLicenses,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$packageCount',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.appName} ${AppConstants.appVersion}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Loading indicator
              if (!_loaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.info),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.licensesLoading,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.2, duration: 400.ms, curve: Curves.easeOut);
  }

  /// Build package list sidebar
  Widget _buildPackageList(List<String> packages) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.package,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.licensesPackages,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          
          // Package list
          Expanded(
            child: _loaded
                ? ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      final isSelected = _selectedPackage == package;
                      final licenses = _groupedLicenses[package]!;
                      
                      return _PackageListItem(
                        package: package,
                        licenseCount: licenses.length,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedPackage = package;
                          });
                        },
                      )
                          .animate()
                          .fadeIn(
                            duration: 300.ms,
                            delay: (index * 20).ms,
                          )
                          .slideX(
                            begin: -0.1,
                            duration: 300.ms,
                            delay: (index * 20).ms,
                          );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.licensesLoadingPackages,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Build license content
  Widget _buildLicenseContent() {
    if (_selectedPackage == null) {
      return _buildEmptyState();
    }

    final licenses = _groupedLicenses[_selectedPackage]!;
    
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Package header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.accent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.fileText,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedPackage!,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        licenses.length == 1 
                            ? '1 ${AppLocalizations.of(context)!.licensesLicense.toLowerCase()}'
                            : AppLocalizations.of(context)!.licensesCount(licenses.length),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, duration: 300.ms),
          
          // License text
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: licenses.length,
              itemBuilder: (context, index) {
                final license = licenses[index];
                return _LicenseCard(
                  license: license,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              LucideIcons.scroll,
              size: 48,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.licensesSelectPackage,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.licensesChoosePackage,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 400.ms);
  }
}

/// Package list item widget
class _PackageListItem extends StatefulWidget {
  final String package;
  final int licenseCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageListItem({
    required this.package,
    required this.licenseCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PackageListItem> createState() => _PackageListItemState();
}

class _PackageListItemState extends State<_PackageListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : (_isHovered
                        ? AppColors.surface.withValues(alpha: 0.8)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : (_isHovered
                          ? AppColors.border.withValues(alpha: 0.3)
                          : Colors.transparent),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      LucideIcons.box,
                      size: 14,
                      color: widget.isSelected
                          ? AppColors.primary
                          : AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.package,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: widget.isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: widget.isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.licenseCount > 1) ...[
                          const SizedBox(height: 2),
                          Builder(
                            builder: (context) => Text(
                              AppLocalizations.of(context)!.licensesCount(widget.licenseCount),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.isSelected)
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// License card widget
class _LicenseCard extends StatelessWidget {
  final LicenseEntry license;
  final int index;

  const _LicenseCard({
    required this.license,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // License header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${l10n.licensesLicense} ${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // License text
          Container(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              license.paragraphs
                  .map((p) => p.text)
                  .join('\n\n'),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                height: 1.6,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideY(begin: 0.1, duration: 300.ms, delay: (index * 50).ms);
  }
}

