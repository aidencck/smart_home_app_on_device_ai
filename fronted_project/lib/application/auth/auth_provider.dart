import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final bool hasAgreedToPrivacy;
  final String? token;
  final String? userId;

  AuthState({
    this.isAuthenticated = false,
    this.hasAgreedToPrivacy = false,
    this.token,
    this.userId,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? hasAgreedToPrivacy,
    String? token,
    String? userId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasAgreedToPrivacy: hasAgreedToPrivacy ?? this.hasAgreedToPrivacy,
      token: token ?? this.token,
      userId: userId ?? this.userId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final hasAgreed = prefs.getBool('privacy_agreed') ?? false;
    
    // Always override mock token for development
    if (token != null && token != 'mock_token') {
      token = 'mock_token';
      await prefs.setString('auth_token', token);
    }
    
    if (token != null) {
      state = AuthState(
        isAuthenticated: true,
        hasAgreedToPrivacy: hasAgreed,
        token: token,
        userId: 'simulated_user_id',
      );
    }
  }

  Future<void> login(String email, String password) async {
    // Mock login logic
    await Future.delayed(const Duration(milliseconds: 500));
    final token = 'mock_token'; // Changed to match backend test fallback
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    
    state = state.copyWith(
      isAuthenticated: true,
      token: token,
      userId: 'simulated_user_id',
    );
  }

  Future<void> agreeToPrivacy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_agreed', true);
    state = state.copyWith(hasAgreedToPrivacy: true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});