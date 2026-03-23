import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/speech_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final speechService = SpeechService();
  await speechService.startListening();

  runApp(const SafeHerApp());
}

class SafeHerApp extends StatelessWidget {
  const SafeHerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SafeHer',
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: const SafeHerHome(),
    );
  }
}
