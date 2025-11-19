import '../../../core/constants/storage_keys.dart';
import '../../models/user_model.dart';
import 'storage_service.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({required this.storageService});

  final StorageService storageService;

  Future<void> saveAuthToken(String token) async {
    await storageService.saveString(StorageKeys.authToken, token);
  }

  Future<String?> getAuthToken() {
    return storageService.getString(StorageKeys.authToken);
  }

  Future<void> saveUser(UserModel user) async {
    await storageService.saveObject(StorageKeys.userData, user.toJson());
  }

  Future<UserModel?> getUser() async {
    final Map<String, dynamic>? json = await storageService.getObject(
      StorageKeys.userData,
    );
    if (json == null) {
      return null;
    }
    return UserModel.fromJson(json);
  }

  Future<void> clearAuthData() async {
    await storageService.remove(StorageKeys.authToken);
    await storageService.remove(StorageKeys.userData);
  }
}
