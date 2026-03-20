import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/speech_service.dart';

// 1. Create a GlobalKey to allow dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Speech Service
  final speechService = SpeechService();
  await speechService.startListening();

  runApp(const SafeHerApp());
}

class SafeHerApp extends StatelessWidget {
  const SafeHerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 3. Register the navigatorKey here
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SafeHer',
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: const SafeHerHome(),
    );
  }
}
