import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../models/member_data.dart';
import '../services/search_service.dart';
import '../services/offline_storage_service.dart';

/// Member search screen with modern design
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final SearchService _searchService;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize SearchService with offline storage
    final offlineStorage = OfflineStorageService();
    _searchService = SearchService(offlineStorage: offlineStorage);
    
    // Load all members on init
    _loadAllMembers();
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
  String _selectedPlan = 'all';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    
    setState(() => _isSearching = true);

    try {
      if (query.isEmpty) {
        // Show all members from local database
        final results = await _searchService.searchMembers('');
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
        return;
      }

      // Search members
      final results = await _searchService.searchMembers(query);

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

  void _showMemberDetails(MemberData member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MemberDetailsSheet(member: member),
    );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchResults.isNotEmpty) ...[
              Text(
                '${_searchResults.length} ${_searchResults.length == 1 ? 'member' : 'members'} found',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        if (_searchController.text.isNotEmpty && _searchResults.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Results',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _performSearch(),
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by name or ID...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                    )
                  : _isSearching
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
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
          
          // Filters row
          Row(
            children: [
              Expanded(child: _buildModernFilterChip('Status', _selectedStatus, ['all', 'active', 'expired', 'inactive'], Icons.verified_user_rounded),),
              const SizedBox(width: 12),
              Expanded(child: _buildModernFilterChip('Plan', _selectedPlan, ['all', 'Monthly', 'Annual', 'Day Pass'], Icons.card_membership_rounded),),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSearching ? null : _performSearch,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: _isSearching ? null : AppColors.primaryGradient,
                    color: _isSearching ? AppColors.border : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isSearching ? null : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSearching ? Icons.hourglass_empty_rounded : Icons.search_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSearching ? 'Searching...' : 'Search Members',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(String label, String value, List<String> items, IconData icon) {
    return PopupMenuButton<String>(
      onSelected: (newValue) {
        setState(() {
          if (label == 'Status') {
            _selectedStatus = newValue;
          } else {
            _selectedPlan = newValue;
          }
        });
        if (_searchController.text.isNotEmpty) {
          _performSearch();
        }
      },
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == 'all' ? 'All ${label}s' : value,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem<String>(
          value: item,
          child: Row(
            children: [
              if (item == value)
                Icon(Icons.check_rounded, size: 16, color: AppColors.primary)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(
                item == 'all' ? 'All ${label}s' : item,
                style: GoogleFonts.inter(
                  color: item == value ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: item == value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
                Icons.qr_code_scanner_rounded,
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
                Icons.person_off_rounded,
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

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final member = _searchResults[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(MemberData member) {
    final statusColor = _getStatusColor(member.membershipStatus);
    final isActive = member.membershipStatus.toLowerCase() == 'active';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card.withValues(alpha: 0.7),
            AppColors.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMemberDetails(member),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with status indicator
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                          border: Border.all(
                            color: AppColors.card,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                
                // Member info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.memberName,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.card_membership_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            member.planName,
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            member.formattedExpiryDate,
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        member.membershipStatus.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
}

/// Member details bottom sheet
class _MemberDetailsSheet extends StatelessWidget {
  final MemberData member;

  const _MemberDetailsSheet({required this.member});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(member.membershipStatus);
    final isActive = member.membershipStatus.toLowerCase() == 'active';
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.card,
            AppColors.surface,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Avatar (large) with status
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: member.hasAvatar ? null : AppColors.primaryGradient,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
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
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      border: Border.all(
                        color: AppColors.card,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      isActive ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Name
            Text(
              member.memberName,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member.membershipStatus.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            
            // Details
            _buildDetailRow(Icons.badge_rounded, 'Member ID', member.memberId),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.card_membership_rounded, 'Plan', member.planName),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today_rounded, 'Expires', member.formattedExpiryDate),
            
            const SizedBox(height: 28),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Close',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
}

