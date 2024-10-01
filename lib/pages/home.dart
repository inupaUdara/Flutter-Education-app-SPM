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
  String username = 'User';

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
            .doc(currentUser.uid)
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
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Display the username at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Hi $username!!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Card grid view
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildNavigationCard(
                  icon: Icons.person,
                  text: 'Profile',
                  onTap: () {
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
                _buildNavigationCard(
                  icon: Icons.calculate,
                  text: 'Maths',
                  onTap: () {
                    Navigator.pushNamed(context, '/maths_obj');
                  },
                ),
                _buildNavigationCard(
                  icon: Icons.science,
                  text: 'Science',
                  onTap: () {
                    Navigator.pushNamed(context, '/science_obj');
                  },
                ),
                _buildNavigationCard(
                  icon: Icons.attach_money,
                  text: 'Currancy',
                  onTap: () {
                    Navigator.pushNamed(context, '/currancy_obj');
                  },
                ),
                _buildNavigationCard(
                  icon: Icons.save_alt,
                  text: 'Saved Object',
                  onTap: () {
                    Navigator.pushNamed(context, '/display_shape_obj');
                  },
                ),
                _buildNavigationCard(
                  icon: Icons.help,
                  text: 'Help',
                  onTap: () {
                    Navigator.pushNamed(context, '/help_page');
                  },
                ),
              ],
            ),
          ),
          SpeechButton(
            onCaptureCommand: () {},
          ),
        ],
      ),
    );
  }

  // Helper method to build the navigation cards
  Widget _buildNavigationCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        // height: 50,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
