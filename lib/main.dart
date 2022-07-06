import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:secured_note_app/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey.shade900,
        brightness: Brightness.dark,
      ),
      home: const AuthPage(),
    );
  }
}
