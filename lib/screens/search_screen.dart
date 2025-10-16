import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../models/member_data.dart';
import '../services/search_service.dart';
import '../services/offline_storage_service.dart';
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
  final TextEditingController _searchController = TextEditingController();
  
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
    
    return filtered;
  }

  void _showMemberDetails(MemberData member) {
    MemberDetailsModal.show(context, member: member);
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
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
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
                  icon: Icons.list_rounded,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Active',
                  value: 'active',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Expired',
                  value: 'expired',
                  icon: Icons.cancel_rounded,
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
            padding: const EdgeInsets.all(12),
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
                
                // Member info - Compact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.memberName,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.planName,
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Expires: ${member.formattedExpiryDate}',
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status badge - Compact
                Container(
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
                    children: [
                      Icon(
                        isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        member.membershipStatus.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 10,
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
