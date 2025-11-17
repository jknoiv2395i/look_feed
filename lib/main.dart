import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/credit_provider.dart';
import 'presentation/providers/keyword_provider.dart';
import 'presentation/providers/exercise_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (_) {}
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<CreditProvider>(create: (_) => CreditProvider()),
        ChangeNotifierProvider<KeywordProvider>(
          create: (_) => KeywordProvider(),
        ),
        ChangeNotifierProvider<ExerciseProvider>(
          create: (_) => ExerciseProvider(),
        ),
      ],
      child: const FeedLockApp(),
    ),
  );
}
