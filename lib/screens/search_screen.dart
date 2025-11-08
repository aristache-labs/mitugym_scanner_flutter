import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_colors.dart';
import '../models/member_data.dart';
import '../services/search_service.dart';
import '../services/offline_storage_service.dart';
import '../services/export_service.dart';
import '../widgets/member_avatar_modal.dart';
import '../widgets/member_details_modal.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: $e'),
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

  void _showMemberDetails(MemberData member) {
    MemberDetailsModal.show(context, member: member);
  }

  /// Export members with format selection
  Future<void> _exportMembers(String format) async {
    final members = _getFilteredMembers();

    if (members.isEmpty) {
      if (mounted) {
        _showPremiumToast(
          'No members to export',
          LucideIcons.alertCircle,
          ToastType.warning,
        );
      }
      return;
    }

    try {
      // Export using selected format
      String? filePath;
      switch (format.toLowerCase()) {
        case 'csv':
          filePath = await _exportService.exportMembersToCSV(members);
          break;
        case 'pdf':
          filePath = await _exportService.exportMembersToPDF(members);
          break;
        case 'txt':
        default:
          filePath = await _exportService.exportMembersToText(members);
      }
      
      if (filePath == null) {
        throw Exception('Export failed: No file path returned');
      }

      if (mounted) {
        _showPremiumToast(
          'Exported ${format.toUpperCase()} to: $filePath',
          LucideIcons.checkCircle,
          ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        _showPremiumToast(
          'Export failed: $e',
          LucideIcons.xCircle,
          ToastType.error,
        );
      }
    }
  }

  /// Show export format menu
  void _showExportMenu(BuildContext context) {
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
              'Export Format',
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
          description: 'Comma-separated values',
          onTap: () => _exportMembers('csv'),
        ),
        _buildExportMenuItem(
          icon: LucideIcons.fileText,
          label: 'PDF',
          description: 'Portable document format',
          onTap: () => _exportMembers('pdf'),
        ),
        _buildExportMenuItem(
          icon: LucideIcons.fileType,
          label: 'TXT',
          description: 'Plain text file',
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
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchResults.isNotEmpty) ...[
              Text(
                '${filteredMembers.length} ${filteredMembers.length == 1 ? 'member' : 'members'} found',
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
                'Export',
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
              hintText: 'Search by name...',
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
                  label: 'All',
                  value: 'all',
                  icon: LucideIcons.list,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Active',
                  value: 'active',
                  icon: LucideIcons.checkCircle,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Expired',
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
              'No Members Yet',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan member QR codes to build your database',
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
              'No Members Found',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Members list with fixed table header
    final filteredMembers = _getFilteredMembers();
    
    return Stack(
      children: [
        // Members list with top padding for header
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filteredMembers.length,
            itemBuilder: (context, index) {
              final member = filteredMembers[index];
              return _buildMemberCard(member);
            },
          ),
        ),
        
        // Fixed table header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTableHeader(),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Member column (with avatar space)
          SizedBox(
            width: 200,
            child: _buildSortableHeader('MEMBER', 'member'),
          ),
          
          // Plan column
          Expanded(
            flex: 2,
            child: _buildSortableHeader('PLAN', 'plan'),
          ),
          
          // Expires column
          Expanded(
            flex: 2,
            child: _buildSortableHeader('EXPIRES', 'expires'),
          ),
          
          // Status column (with sorting)
          SizedBox(
            width: 100,
            child: _buildSortableHeader('STATUS', 'status'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortableHeader(String label, String sortKey) {
    final isActive = _sortBy == sortKey;
    
    return InkWell(
      onTap: () => _toggleSort(sortKey),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive
                  ? (_sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown)
                  : LucideIcons.arrowUpDown,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(MemberData member) {
    final statusColor = _getStatusColor(member.membershipStatus);
    final isActive = member.membershipStatus.toLowerCase() == 'active';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.7),
            AppColors.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        onTap: () => _showMemberDetails(member),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
                // Member column (with avatar) - matches header width: 200
                SizedBox(
                  width: 200,
                  child: Row(
                  children: [
                      // Compact Avatar (clickable to expand)
                      GestureDetector(
                        onTap: () {
                          MemberAvatarModal.show(
                            context,
                            avatarUrl: member.avatarUrl,
                            memberName: member.memberName,
                            memberId: member.memberId,
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: member.hasAvatar ? null : AppColors.primaryGradient,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            image: member.hasAvatar
                                ? DecorationImage(
                                    image: NetworkImage(member.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: member.hasAvatar
                              ? null
                              : Center(
                                  child: Text(
                                    member.initials,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Member name
                      Expanded(
                        child: Text(
                          member.memberName,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
                // Plan column - matches header flex: 2
                Expanded(
                  flex: 2,
                  child: Text(
                    member.planName,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Expires column - matches header flex: 2
                Expanded(
                  flex: 2,
                  child: Text(
                    member.formattedExpiryDate,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                // Status column - matches header width: 100
                SizedBox(
                  width: 100,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? LucideIcons.checkCircle : LucideIcons.xCircle,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                child: Text(
                  member.membershipStatus.toUpperCase(),
                            style: GoogleFonts.inter(
                    color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'expired':
        return AppColors.error;
      case 'inactive':
        return AppColors.warning;
      default:
        return AppColors.muted;
    }
  }

  // Premium Toast Helper
  void _showPremiumToast(String message, IconData icon, ToastType type) {
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
  final VoidCallback onDismiss;

  const _PremiumToast({
    required this.message,
    required this.icon,
    required this.color,
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
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
                  minWidth: 300,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.card.withValues(alpha: 0.95),
                      AppColors.surface.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 16,
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
    );
  }
}

/// Member details bottom sheet
