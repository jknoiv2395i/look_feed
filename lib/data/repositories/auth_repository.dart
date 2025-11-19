import '../../domain/entities/user_entity.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';

class AuthRepository {
  AuthRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  Future<UserEntity> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ValidationException('Email and password are required');
    }
    final UserModel userModel = await remoteDataSource.login(email, password);
    await localDataSource.saveAuthToken('dummy-token');
    await localDataSource.saveUser(userModel);
    return userModel.toEntity();
  }

  Future<UserEntity> register(
    String email,
    String password,
    String? name,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      throw ValidationException('Email and password are required');
    }
    final UserModel userModel = await remoteDataSource.register(
      email,
      password,
      name,
    );
    await localDataSource.saveAuthToken('dummy-token');
    await localDataSource.saveUser(userModel);
    return userModel.toEntity();
  }

  Future<void> logout() async {
    await remoteDataSource.logout();
    await localDataSource.clearAuthData();
  }

  Future<UserEntity?> getCurrentUser() async {
    final UserModel? userModel = await localDataSource.getUser();
    if (userModel == null) {
      return null;
    }
    return userModel.toEntity();
  }
}
