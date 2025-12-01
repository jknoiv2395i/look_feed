import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/app.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/local/storage_service.dart';
import 'data/datasources/remote/api_client.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/credit_provider.dart';
import 'presentation/providers/keyword_provider.dart';
import 'presentation/providers/exercise_provider.dart';
import 'presentation/providers/exercise_stats_provider.dart';
import 'presentation/providers/summary_provider.dart';
import 'presentation/providers/feed_provider.dart';
import 'presentation/providers/niche_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (_) {}
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  final ApiClient apiClient = ApiClient();
  final StorageService storageService = StorageService();
  final AuthLocalDataSource authLocalDataSource = AuthLocalDataSource(
    storageService: storageService,
  );
  final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSource(
    apiClient: apiClient,
  );
  final AuthRepository authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );

  runApp(
    MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<CreditProvider>(
          create: (_) => CreditProvider()..fetchCredits(),
        ),
        ChangeNotifierProvider<KeywordProvider>(
          create: (_) => KeywordProvider(),
        ),
        ChangeNotifierProvider<ExerciseProvider>(
          create: (_) => ExerciseProvider(),
        ),
        ChangeNotifierProvider<ExerciseStatsProvider>(
          create: (_) => ExerciseStatsProvider()..fetchSessions(),
        ),
        ChangeNotifierProvider<SummaryProvider>(
          create: (_) => SummaryProvider(),
        ),
        ChangeNotifierProvider<FeedProvider>(create: (_) => FeedProvider()),
        ChangeNotifierProvider<NicheProvider>(create: (_) => NicheProvider()),
      ],
      child: const FeedLockApp(),
    ),
  );
}
