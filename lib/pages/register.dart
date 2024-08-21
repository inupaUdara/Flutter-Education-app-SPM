import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spm_project/component/button.dart';
import 'package:spm_project/helper/helper_function.dart';
import '../component/textfield.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? ontap;
  const RegisterPage({
    super.key,
    required this.ontap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  final storage = new FlutterSecureStorage();
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await auth.canCheckBiometrics;
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isBiometricAvailable) {
      try {
        final authenticated = await auth.authenticate(
          localizedReason: "Please authenticate to register",
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );
        if (authenticated) {
          await register();
        } else {
          displayMessageToUser("Authentication failed", context);
        }
      } catch (e) {
        displayMessageToUser("Error using biometrics: $e", context);
      }
    } else {
      displayMessageToUser("Biometric authentication not available", context);
    }
  }

  Future<void> register() async {
    // Show loading dialog
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPwController.text.isEmpty) {
      Navigator.pop(context); // Close loading dialog
      displayMessageToUser("All fields are required!", context);
      return;
    }

    // Validate that password and confirm password match
    if (passwordController.text != confirmPwController.text) {
      Navigator.pop(context); // Close loading dialog
      displayMessageToUser("Passwords don't match!", context);
      return;
    }

    try {
      // Register the user with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Create the user's document in Firestore
      await createUserDocument(userCredential);
      await storage.write(key: 'username', value: usernameController.text);
      await storage.write(key: 'email', value: emailController.text);
      await storage.write(key: 'password', value: passwordController.text);

      // Dismiss the loading dialog and show success message
      if (context.mounted) {
        Future.delayed(Duration.zero, () {
          Navigator.pop(context); // Close loading dialog
          displayMessageToUser("Registration successful", context);
        });
      }
    } on FirebaseAuthException catch (e) {
      // Handle registration errors
      Future.delayed(Duration.zero, () {
        Navigator.pop(context); // Close loading dialog
        displayMessageToUser(e.message ?? "Registration failed", context);
      });
      // Navigator.pushNamed(context, '/login_register_page');
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "Register",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 25,
                ),
                CustomTextField(
                  hintText: "Username",
                  obscureText: false,
                  controller: usernameController,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPwController,
                ),
                const SizedBox(
                  height: 25,
                ),
                _isBiometricAvailable
                    ? CustomButton(
                        text: "Register with Fingerprint",
                        ontap: _authenticateWithBiometrics,
                      )
                    : CustomButton(
                        text: "Register",
                        ontap: register,
                      ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.ontap,
                      child: Text(
                        " Login here",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
