import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../shared/data/models/api_response.dart';
import '../../../shared/data/models/auth_models.dart';
import '../../../shared/data/services/fcm_service.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? role;
  final String? username;
  final String? errorMessage;
  final UserProfileResponse? userProfile;

  AuthState({
    required this.status,
    this.token,
    this.role,
    this.username,
    this.errorMessage,
    this.userProfile,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? role,
    String? username,
    String? errorMessage,
    UserProfileResponse? userProfile,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      role: role ?? this.role,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState(status: AuthStatus.initial)) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final role = prefs.getString('user_role');
      final username = prefs.getString('username');

      if (token != null && token.isNotEmpty) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          role: role,
          username: username,
        );
        // Register FCM Token with backend
        _ref.read(fcmServiceProvider).registerToken();
        // Fetch fresh profile in the background
        await fetchUserProfile();
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e, stack) {
      print('ERROR IN CHECKAUTHSTATUS: $e');
      print(stack);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<JwtAuthResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => JwtAuthResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final authData = apiResponse.data!;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', authData.accessToken);
        await prefs.setString('user_role', authData.role);
        await prefs.setString('username', authData.username);

        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: authData.accessToken,
          role: authData.role,
          username: authData.username,
        );

        // Register FCM Token with backend
        _ref.read(fcmServiceProvider).registerToken();

        // Fetch user profile details
        await fetchUserProfile();
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: apiResponse.message.isNotEmpty ? apiResponse.message : 'Invalid login credentials.',
        );
      }
    } on DioException catch (e) {
      String msg = 'Connection failed.';
      if (e.response != null && e.response?.data != null) {
        try {
          final errJson = e.response?.data as Map<String, dynamic>;
          msg = errJson['message'] as String? ?? 'Authentication failed.';
        } catch (_) {
          msg = e.response?.statusMessage ?? 'Login failed.';
        }
      }
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'An unexpected error occurred.');
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.get(ApiConstants.userMe);
      
      final apiResponse = ApiResponse<UserProfileResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserProfileResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final profile = apiResponse.data!;
        state = state.copyWith(userProfile: profile);

        if (profile.role == 'FARMER') {
          await HiveService.cacheData('farmer_assignments_${profile.username}', profile.assignedZones);
          await HiveService.cacheData('has_configured_assignments_${profile.username}', true);
        }
      }
    } catch (e) {
      // If fetching fails, we keep the authenticated state with basic info
      print('Failed to fetch user profile: $e');
    }
  }

  Future<void> updateProfileLocal(String newUsername, String newEmail) async {
    if (state.userProfile != null) {
      final updated = UserProfileResponse(
        id: state.userProfile!.id,
        username: newUsername,
        email: newEmail,
        role: state.userProfile!.role,
        assignedZones: state.userProfile!.assignedZones,
      );
      state = state.copyWith(userProfile: updated, username: newUsername);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', newUsername);
    }
  }

  Future<void> logout() async {
    // Unregister FCM Token from backend
    await _ref.read(fcmServiceProvider).unregisterToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_role');
    await prefs.remove('username');

    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
