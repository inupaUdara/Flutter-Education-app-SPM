import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/auth/auth.dart';
import 'package:spm_project/auth/loginOrRegister.dart';
import 'package:spm_project/firebase_options.dart';
import 'package:spm_project/pages/home.dart';
import 'package:spm_project/pages/profile.dart';
import 'package:spm_project/theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: colorMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => const HomePage(),
        '/profile_page': (context) => const ProfilePage(),
      },
    );
  }
}
