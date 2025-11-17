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
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onUnknownRoute: (settings) =>
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }
}
