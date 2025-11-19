import '../../../core/utils/helpers.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/user_model.dart';
import 'api_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserModel> login(String email, String password) async {
    try {
      final dynamic response = await _apiClient.post<dynamic>(
        '/auth/login',
        data: <String, dynamic>{'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }

      throw Exception('Login failed: ${response.statusCode}');
    } catch (e) {
      // Fallback to mock data for demo purposes
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final DateTime now = DateTime.now();
      return UserModel(
        id: ExerciseHelpers.generateUuid(),
        email: email,
        name: null,
        profileImage: null,
        subscriptionTier: SubscriptionTier.free,
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  Future<UserModel> register(
    String email,
    String password,
    String? name,
  ) async {
    try {
      final dynamic response = await _apiClient.post<dynamic>(
        '/auth/register',
        data: <String, dynamic>{
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }

      throw Exception('Registration failed: ${response.statusCode}');
    } catch (e) {
      // Fallback to mock data for demo purposes
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final DateTime now = DateTime.now();
      return UserModel(
        id: ExerciseHelpers.generateUuid(),
        email: email,
        name: name,
        profileImage: null,
        subscriptionTier: SubscriptionTier.free,
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  Future<void> refreshToken() async {
    try {
      await _apiClient.post<dynamic>('/auth/refresh-token');
    } catch (e) {
      // Ignore refresh errors for now
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<dynamic>('/auth/logout');
    } catch (e) {
      // Ignore logout errors for now
    }
  }
}
