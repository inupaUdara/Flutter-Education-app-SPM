import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/auth/loginOrRegister.dart';
import 'package:spm_project/pages/home.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              // User is signed in, show the home page
              return const HomePage();
            } else {
              // User is not signed in, show the login/register page
              return const LoginOrRegister();
            }
          }),
    );
  }
}
