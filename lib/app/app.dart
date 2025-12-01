import 'package:flutter/material.dart';

import '../presentation/screens/home/home_screen.dart';
import 'routes.dart';
import 'theme.dart';

class FeedLockApp extends StatelessWidget {
  const FeedLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feed Lock',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.onboarding,
      onGenerateRoute: AppRoutes.generateRoute,
      onUnknownRoute: (settings) =>
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }
}
