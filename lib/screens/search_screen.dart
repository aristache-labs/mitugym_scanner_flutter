import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../models/member_data.dart';
import '../providers/config_provider.dart';
import '../services/search_service.dart';
import '../services/offline_storage_service.dart';
import '../services/export_service.dart';
import '../widgets/unified_member_table.dart';
import '../l10n/app_localizations.dart';

/// Member search screen with modern design
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final SearchService _searchService;
  final ExportService _exportService = ExportService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _exportButtonKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    // Initialize SearchService with offline storage
    final offlineStorage = OfflineStorageService();
    _searchService = SearchService(offlineStorage: offlineStorage);
    
    // Add listener for real-time search
    _searchController.addListener(_onSearchChanged);
    
    // Load all members on init
    _loadAllMembers();
  }
  
  void _onSearchChanged() {
    // Trigger search as user types
    _performSearch();
  }
  
  Future<void> _loadAllMembers() async {
    setState(() => _isSearching = true);
    try {
      final results = await _searchService.searchMembers('');
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }
  
  List<MemberData> _searchResults = [];
  bool _isSearching = false;
  String _selectedStatus = 'all';
  String _sortBy = ''; // No default sorting - clean state
  bool _sortAscending = true;
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    setState(() => _isSearching = true);

    try {
      List<MemberData> results;
      
      if (query.isEmpty) {
        // Show all members from local database
        results = await _searchService.searchMembers('');
      } else {
        // Search members
        results = await _searchService.searchMembers(query);
      }
      
      // Apply filters
      results = _applyFilters(results);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.searchError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  List<MemberData> _applyFilters(List<MemberData> members) {
    var filtered = members;
    
    // Filter by status
    if (_selectedStatus != 'all') {
      filtered = filtered.where((member) {
        return member.membershipStatus.toLowerCase() == _selectedStatus.toLowerCase();
      }).toList();
    }
    
    // Apply sorting
    filtered = _applySorting(filtered);
    
    return filtered;
  }
  
  List<MemberData> _applySorting(List<MemberData> members) {
    // If no sort is selected, return original order
    if (_sortBy.isEmpty) {
      return members;
    }
    
    final sorted = List<MemberData>.from(members);
    
    sorted.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'member':
          comparison = a.memberName.toLowerCase().compareTo(b.memberName.toLowerCase());
          break;
        case 'plan':
          comparison = a.planName.toLowerCase().compareTo(b.planName.toLowerCase());
          break;
        case 'expires':
          comparison = a.expiresAt.compareTo(b.expiresAt);
          break;
        case 'status':
          comparison = a.membershipStatus.toLowerCase().compareTo(b.membershipStatus.toLowerCase());
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return sorted;
  }
  
  void _toggleSort(String sortKey) {
    setState(() {
      if (_sortBy == sortKey) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortKey;
        _sortAscending = true;
      }
    });
    _performSearch();
  }


  /// Export members with format selection
  Future<void> _exportMembers(String format) async {
    final members = _getFilteredMembers();
    
    // Get localization early to avoid BuildContext issues
    final l10n = AppLocalizations.of(context)!;

    if (members.isEmpty) {
      if (mounted) {
        _showPremiumToast(
          l10n.noMembersToExport,
          LucideIcons.alertCircle,
          ToastType.warning,
        );
      }
      return;
    }

    try {
      // Get custom export path from config
      final config = ref.read(configProvider);
      final customPath = config.exportPath.isNotEmpty ? config.exportPath : null;
      
      // Export using selected format
      String? filePath;
      switch (format.toLowerCase()) {
        case 'csv':
          filePath = await _exportService.exportMembersToCSV(members, customPath: customPath);
          break;
        case 'pdf':
          filePath = await _exportService.exportMembersToPDF(members, customPath: customPath);
          break;
        case 'txt':
        default:
          filePath = await _exportService.exportMembersToText(members, customPath: customPath);
      }
      
      if (filePath == null) {
        throw Exception(l10n.exportFailed('No file path returned'));
      }

      if (mounted) {
        _showPremiumToast(
          l10n.exportedTo(format.toUpperCase(), filePath),
          LucideIcons.checkCircle,
          ToastType.success,
          filePath: filePath,
        );
      }
    } catch (e) {
      if (mounted) {
        _showPremiumToast(
          l10n.exportFailed(e.toString()),
          LucideIcons.xCircle,
          ToastType.error,
        );
      }
    }
  }

  /// Show export format menu
  void _showExportMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final RenderBox? renderBox = _exportButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width - 200, // Align right edge of menu with button
        offset.dy + size.height + 8, // 8px below the button
        MediaQuery.of(context).size.width - offset.dx - size.width,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      color: AppColors.card,
      elevation: 8,
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          enabled: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              l10n.exportFormat,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        _buildExportMenuItem(
          icon: LucideIcons.fileSpreadsheet,
          label: 'CSV',
          description: l10n.csvDescription,
          onTap: () => _exportMembers('csv'),
        ),
        _buildExportMenuItem(
          icon: LucideIcons.fileText,
          label: 'PDF',
          description: l10n.pdfDescription,
          onTap: () => _exportMembers('pdf'),
        ),
        _buildExportMenuItem(
          icon: LucideIcons.fileType,
          label: 'TXT',
          description: l10n.txtDescription,
          onTap: () => _exportMembers('txt'),
        ),
      ],
    );
  }

  /// Build a single export menu item
  PopupMenuItem _buildExportMenuItem({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  /// Get filtered members based on current filters
  List<MemberData> _getFilteredMembers() {
    var filtered = _searchResults;

    // Apply status filter
    if (_selectedStatus != 'all') {
      filtered = filtered.where((m) {
        if (_selectedStatus == 'active') return m.isActive;
        if (_selectedStatus == 'inactive') return !m.isActive;
        return true;
      }).toList();
    }

    // Apply sorting
    if (_sortBy.isNotEmpty) {
      filtered = List.from(filtered);
      filtered.sort((a, b) {
        int comparison = 0;
        switch (_sortBy) {
          case 'name':
            comparison = a.memberName.compareTo(b.memberName);
            break;
          case 'plan':
            comparison = a.planName.compareTo(b.planName);
            break;
          case 'expiry':
            try {
              final dateA = DateTime.parse(a.expiresAt);
              final dateB = DateTime.parse(b.expiresAt);
              comparison = dateA.compareTo(dateB);
            } catch (e) {
              comparison = 0;
            }
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search header with stats
        _buildSearchHeader(),
        const SizedBox(height: 16),
        
        // Search bar and filters
        _buildSearchSection(),
        const SizedBox(height: 16),

        // Search results
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    final filteredMembers = _getFilteredMembers();
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchResults.isNotEmpty) ...[
              Text(
                filteredMembers.length == 1 
                    ? l10n.memberFound(filteredMembers.length)
                    : l10n.membersFound(filteredMembers.length),
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        // Export button
        ElevatedButton.icon(
          key: _exportButtonKey,
          onPressed: () => _showExportMenu(context),
          icon: const Icon(LucideIcons.download, size: 16),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.export,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.chevronDown,
                size: 14,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            foregroundColor: AppColors.primary.withValues(alpha: 0.95),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.9),
            AppColors.surface.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
            ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
                TextField(
                  controller: _searchController,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchByNameMembers,
              hintStyle: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(LucideIcons.x, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                        // Search will trigger automatically via listener
                            },
                          )
                        : null,
                    filled: true,
              fillColor: AppColors.surface.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                  children: [
                _buildFilterChip(
                  label: AppLocalizations.of(context)!.all,
                  value: 'all',
                  icon: LucideIcons.list,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: AppLocalizations.of(context)!.active,
                  value: 'active',
                  icon: LucideIcons.checkCircle,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: AppLocalizations.of(context)!.expired,
                  value: 'expired',
                  icon: LucideIcons.xCircle,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final isSelected = _selectedStatus == value;
    final chipColor = color ?? AppColors.primary;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = value;
        });
        _performSearch();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? chipColor : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? chipColor : AppColors.textMuted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    if (_searchController.text.isEmpty && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.qrCode,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noMembersYet,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.scanMemberQRToBuild,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.userX,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noMembersFound,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tryAdjustingFilters,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Members list using unified table component
    final filteredMembers = _getFilteredMembers();
    
    return UnifiedMemberTable(
      members: filteredMembers,
      sortBy: _sortBy,
      sortAscending: _sortAscending,
      onSort: _toggleSort,
      showHeader: true,
    );
  }


  // Premium Toast Helper
  void _showPremiumToast(String message, IconData icon, ToastType type, {String? filePath}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PremiumToast(
        message: message,
        icon: icon,
        color: type == ToastType.success
            ? AppColors.success
            : type == ToastType.error
                ? AppColors.error
                : AppColors.warning,
        filePath: filePath,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

enum ToastType { success, error, warning }

class _PremiumToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final String? filePath;
  final VoidCallback onDismiss;

  const _PremiumToast({
    required this.message,
    required this.icon,
    required this.color,
    this.filePath,
    required this.onDismiss,
  });

  @override
  State<_PremiumToast> createState() => _PremiumToastState();
}

class _PremiumToastState extends State<_PremiumToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      reverseCurve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFile() async {
    if (widget.filePath == null) return;
    
    try {
      final uri = Uri.file(widget.filePath!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: MouseRegion(
                cursor: widget.filePath != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: widget.filePath != null ? _openFile : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                      minWidth: 300,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.card.withValues(alpha: _isHovered && widget.filePath != null ? 1.0 : 0.95),
                          AppColors.surface.withValues(alpha: _isHovered && widget.filePath != null ? 0.95 : 0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.color.withValues(alpha: _isHovered && widget.filePath != null ? 0.5 : 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: _isHovered && widget.filePath != null ? 32 : 24,
                          offset: Offset(0, _isHovered && widget.filePath != null ? 16 : 12),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: widget.color.withValues(alpha: _isHovered && widget.filePath != null ? 0.3 : 0.2),
                          blurRadius: _isHovered && widget.filePath != null ? 20 : 16,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color.withValues(alpha: 0.9),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Member details bottom sheet
