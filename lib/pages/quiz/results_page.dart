import 'package:flutter/material.dart';
// import 'package:flutter_text_to_speech_tutorial/home_page.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lottie/lottie.dart';
import 'package:spm_project/pages/home.dart'; // Import Lottie for animations

class ResultsPage extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const ResultsPage({
    required this.score,
    required this.totalQuestions,
    super.key,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    initTTS();
    initSpeech();
  }

  Future<void> initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts
        .speak("You scored ${widget.score} out of ${widget.totalQuestions}.");
  }

  Future<void> initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled && !_isListening) {
      setState(() {
        _isListening = true;
      });

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        cancelOnError: true,
      );
    }
  }

  void _stopListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      await _speechToText.stop();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final userCommand = result.recognizedWords.toLowerCase();
    print('Recognized Command: $userCommand'); // Debugging line

    if (userCommand.contains('back to home')) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'You scored ${widget.score} out of ${widget.totalQuestions}.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onLongPress: _startListening,
                onLongPressUp: _stopListening,
                child: Container(
                  width: double.infinity,
                  height: 400,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Center(
                    child: _isListening
                        ? Lottie.network(
                            'https://lottie.host/d6546831-1930-48d4-9e82-70fa2aeca5f9/8kIDv5qgMv.json',
                            width: 300,
                            height: 300,
                          )
                        : const Icon(
                            Icons.mic_none,
                            size: 180,
                            color: Color.fromARGB(
                                255, 1, 197, 24), // Consistent color
                          ),
                  ),
                ),
              ),
              // const SizedBox(height: 120),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: (context) => const HomePage()),
              //       (Route<dynamic> route) => false,
              //     );
              //   },
              //   child: const Text('Back to Home'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
