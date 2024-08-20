import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/auth/auth.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _command = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _command = result.recognizedWords;
        _navigateBasedOnCommand(_command.toLowerCase());
      });
    });
    setState(() {
      _speechEnabled = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _speechEnabled = false;
    });
  }

  void _navigateBasedOnCommand(String command) {
    if (command.contains('home')) {
      Navigator.pushNamed(context, '/home_page');
    } else if (command.contains('profile')) {
      Navigator.pushNamed(context, '/profile_page');
    } else if (command.contains('logout')) {
      widget.logout(context);
    }

    print(_command);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 25.0),
              //   child: ListTile(
              //     leading: Icon(
              //       Icons.home,
              //       color: Theme.of(context).colorScheme.inversePrimary,
              //     ),
              //     title: Text("HOME"),
              //     onTap: () {
              // Navigator.pushNamed(context, "/home_page");
              //     },
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: Text("PROFILE"),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    _speechToText.isListening ? Icons.mic : Icons.mic_none,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("VOICE COMMAND"),
                  onTap: _speechEnabled ? _startListening : _stopListening,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
