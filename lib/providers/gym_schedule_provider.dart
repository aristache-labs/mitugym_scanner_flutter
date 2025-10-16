import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gym_schedule.dart';
import '../services/api_service.dart';
import 'config_provider.dart';
import 'auth_provider.dart';

/// Gym Schedule State
class GymScheduleState {
  final GymSchedule? schedule;
  final bool isLoading;
  final String? error;

  const GymScheduleState({
    this.schedule,
    this.isLoading = false,
    this.error,
  });

  GymScheduleState copyWith({
    GymSchedule? schedule,
    bool? isLoading,
    String? error,
  }) {
    return GymScheduleState(
      schedule: schedule ?? this.schedule,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Gym Schedule Notifier
class GymScheduleNotifier extends Notifier<GymScheduleState> {
  @override
  GymScheduleState build() => const GymScheduleState();

  /// Fetch today's gym schedule
  Future<void> fetchSchedule() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final config = ref.read(configProvider);
      final authState = ref.read(authProvider);

      if (!authState.isAuthenticated) {
        state = state.copyWith(
          isLoading: false,
          error: 'Not authenticated',
        );
        return;
      }

      // Use the scanner's API key (from config), not the user's session API key
      final apiService = ApiService(
        apiUrl: config.apiUrl,
        apiKey: config.apiKey, // This is the check-in/scanner API key
      );

      final schedule = await apiService.fetchGymSchedule();

      state = state.copyWith(
        schedule: schedule,
        isLoading: false,
        error: schedule == null ? 'Failed to fetch schedule' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get opening hour (null if gym is closed or schedule not loaded)
  int? get openHour => state.schedule?.openHour;

  /// Get closing hour (null if gym is closed or schedule not loaded)
  int? get closeHour => state.schedule?.closeHour;

  /// Check if gym is open at a specific hour
  bool isOpenAtHour(int hour) {
    return state.schedule?.isOpenAtHour(hour) ?? true; // Default to open if no schedule
  }

  /// Check if gym is closed today
  bool get isClosedToday => state.schedule?.isClosed ?? false;
}

/// Gym Schedule Provider
final gymScheduleProvider = NotifierProvider<GymScheduleNotifier, GymScheduleState>(
  GymScheduleNotifier.new,
);

