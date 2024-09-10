import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:spm_project/auth/auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechButton extends StatefulWidget {
  const SpeechButton({super.key});

  @override
  State<SpeechButton> createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton> {
  SpeechToText _speechToText = SpeechToText();
  FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  bool _isListning = false;
  String _command = '';
  Timer? _timer;

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

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
      _isListning = true;
    });

    _timer = Timer(Duration(seconds: 10), _stopListening);
  }

  void _stopListening() async {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    await _speechToText.stop();
    setState(() {
      _speechEnabled = false;
      _isListning = false;
    });
  }

  void _navigateBasedOnCommand(String command) async {
    if (command.contains('home')) {
      Navigator.pushNamed(context, '/home_page');
      // _speak("Navigating to Home Page");
    } else if (command.contains('profile')) {
      Navigator.pushNamed(context, '/profile_page');
      _speak("Navigating to Profile Page");
    } else if (command.contains('logout')) {
      logout(context);
      _speak("Logging out");
    }
    print(_command);
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      // Stop any previous speech
      await _flutterTts.stop();

      // Optionally set other properties before speaking
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Speed control
      await _flutterTts.setVolume(1.0); // Volume control
      await _flutterTts.setPitch(1.0); // Pitch control

      // Speak the text
      int result = await _flutterTts.speak(text);

      if (result == 1) {
        print("Speech started");
      } else {
        print("Speech failed");
      }
    } else {
      print("No text to speak");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: FloatingActionButton(
                    elevation: 0,
                    onPressed: _startListening,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      _speechToText.isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_isListning)
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: FloatingActionButton(
                      elevation: 0,
                      onPressed: _stopListening,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.stop,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
