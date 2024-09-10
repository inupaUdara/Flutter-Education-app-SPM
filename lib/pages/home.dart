import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/component/drawer.dart';
import 'package:spm_project/component/voice.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts = FlutterTts();
  String username = '';

  @override
  void initState() {
    super.initState();
    getUsernameAndGreet();
  }

  Future<void> getUsernameAndGreet() async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Fetch the user's document from Firestore
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.email)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? 'User';
          });

          // Greet the user using TTS
          await _speak("Hello, $username You are in home page");
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "H O M E",
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      drawer: CustomDrawer(),
      body: SpeechButton(),
    );
  }
}
