import 'package:dora/screen/splash_screen.dart';
import 'package:dora/screen/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dora/state/player_state_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dora/services/firebase_service.dart';
import 'package:dora/controllers/content_controller.dart';

Future<void> main() async {
  // Ensure that the Flutter bindings are initialized before any async work.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Firebase Service (but don't sign in automatically)
  await FirebaseService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerStateNotifier()),
        ChangeNotifierProvider(create: (_) => ContentController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dora App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A0DAD)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      onGenerateRoute: generateRoute,
    );
  }
}
