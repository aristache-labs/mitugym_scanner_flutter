import 'package:logger/logger.dart';
import '../models/member_data.dart';
import 'offline_storage_service.dart';
import 'api_service.dart';

/// Search service for finding members
/// Supports local and remote search with fuzzy matching
class SearchService {
  final OfflineStorageService _offlineStorage;
  final ApiService? _apiService;
  final Logger _logger = Logger();
  
  SearchService({
    required OfflineStorageService offlineStorage,
    ApiService? apiService,
  })  : _offlineStorage = offlineStorage,
        _apiService = apiService;
  
  /// Search members by query string
  /// Searches in local database first, then falls back to API if available
  Future<List<MemberData>> searchMembers(
    String query, {
    bool localOnly = false,
  }) async {
    try {
      if (query.isEmpty) {
        return await _offlineStorage.getOfflineMembers(limit: 50);
      }
      
      // Search in local database
      final localResults = await _offlineStorage.searchMembers(query);
      _logger.d('Found ${localResults.length} local results for: $query');
      
      // If we have local results or local-only mode, return them
      if (localResults.isNotEmpty || localOnly || _apiService == null) {
        return _sortByRelevance(localResults, query);
      }
      
      // For now, just return local results
      return _sortByRelevance(localResults, query);
    } catch (e) {
      _logger.e('Search failed: $e');
      return [];
    }
  }
  
  /// Filter members by membership status
  Future<List<MemberData>> filterByStatus(String status) async {
    try {
      final results = await _offlineStorage.getOfflineMembers(
        statusFilter: status,
        limit: 200,
      );
      _logger.d('Found ${results.length} members with status: $status');
      return results;
    } catch (e) {
      _logger.e('Filter by status failed: $e');
      return [];
    }
  }
  
  /// Get members by plan type
  Future<List<MemberData>> filterByPlan(String planName) async {
    try {
      final allMembers = await _offlineStorage.getOfflineMembers(limit: 500);
      final filtered = allMembers
          .where((m) => m.planName.toLowerCase().contains(planName.toLowerCase()))
          .toList();
      _logger.d('Found ${filtered.length} members with plan: $planName');
      return filtered;
    } catch (e) {
      _logger.e('Filter by plan failed: $e');
      return [];
    }
  }
  
  /// Sort members by date (most recent first)
  List<MemberData> sortByDate(List<MemberData> members) {
    try {
      final sorted = List<MemberData>.from(members);
      sorted.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.expiresAt);
          final dateB = DateTime.parse(b.expiresAt);
          return dateB.compareTo(dateA); // Descending order
        } catch (e) {
          return 0;
        }
      });
      return sorted;
    } catch (e) {
      _logger.e('Sort by date failed: $e');
      return members;
    }
  }
  
  /// Sort by name alphabetically
  List<MemberData> sortByName(List<MemberData> members) {
    final sorted = List<MemberData>.from(members);
    sorted.sort((a, b) => a.memberName.compareTo(b.memberName));
    return sorted;
  }
  
  /// Sort members by relevance to search query
  List<MemberData> _sortByRelevance(List<MemberData> members, String query) {
    if (query.isEmpty) return members;
    
    final queryLower = query.toLowerCase();
    final sorted = List<MemberData>.from(members);
    
    sorted.sort((a, b) {
      // Exact match scores highest
      final aExact = a.memberName.toLowerCase() == queryLower ||
          a.memberId.toLowerCase() == queryLower;
      final bExact = b.memberName.toLowerCase() == queryLower ||
          b.memberId.toLowerCase() == queryLower;
      
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      
      // Starts with query scores second
      final aStarts = a.memberName.toLowerCase().startsWith(queryLower);
      final bStarts = b.memberName.toLowerCase().startsWith(queryLower);
      
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      
      // Contains query scores third
      final aContains = a.memberName.toLowerCase().contains(queryLower);
      final bContains = b.memberName.toLowerCase().contains(queryLower);
      
      if (aContains && !bContains) return -1;
      if (!aContains && bContains) return 1;
      
      // Finally sort alphabetically
      return a.memberName.compareTo(b.memberName);
    });
    
    return sorted;
  }
  
  /// Calculate fuzzy match score (Levenshtein distance)
  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    
    final matrix = List.generate(
      a.length + 1,
      (i) => List.filled(b.length + 1, 0),
    );
    
    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }
    
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[a.length][b.length];
  }
  
  /// Fuzzy search with similarity threshold
  Future<List<MemberData>> fuzzySearch(
    String query, {
    double similarityThreshold = 0.6,
  }) async {
    try {
      final allMembers = await _offlineStorage.getOfflineMembers(limit: 500);
      
      if (query.isEmpty) return allMembers;
      
      final queryLower = query.toLowerCase();
      final results = <MemberData>[];
      
      for (final member in allMembers) {
        final nameLower = member.memberName.toLowerCase();
        final distance = _levenshteinDistance(queryLower, nameLower);
        final maxLength = queryLower.length > nameLower.length
            ? queryLower.length
            : nameLower.length;
        final similarity = 1 - (distance / maxLength);
        
        if (similarity >= similarityThreshold) {
          results.add(member);
        }
      }
      
      _logger.d('Fuzzy search found ${results.length} results for: $query');
      return _sortByRelevance(results, query);
    } catch (e) {
      _logger.e('Fuzzy search failed: $e');
      return [];
    }
  }
  
  /// Get recently active members
  Future<List<MemberData>> getRecentlyActive({int limit = 20}) async {
    try {
      // Get all members and sort by last updated
      final members = await _offlineStorage.getOfflineMembers(limit: limit);
      return members;
    } catch (e) {
      _logger.e('Get recently active failed: $e');
      return [];
    }
  }
  
  /// Get member statistics
  Future<Map<String, int>> getMemberStats() async {
    try {
      final allMembers = await _offlineStorage.getOfflineMembers(limit: 10000);
      
      final stats = <String, int>{
        'total': allMembers.length,
        'active': 0,
        'expired': 0,
        'inactive': 0,
      };
      
      for (final member in allMembers) {
        switch (member.membershipStatus.toLowerCase()) {
          case 'active':
            stats['active'] = (stats['active'] ?? 0) + 1;
            break;
          case 'expired':
            stats['expired'] = (stats['expired'] ?? 0) + 1;
            break;
          case 'inactive':
            stats['inactive'] = (stats['inactive'] ?? 0) + 1;
            break;
        }
      }
      
      return stats;
    } catch (e) {
      _logger.e('Get member stats failed: $e');
      return {'total': 0, 'active': 0, 'expired': 0, 'inactive': 0};
    }
  }
}

