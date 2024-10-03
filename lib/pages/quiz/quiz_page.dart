import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'results_page.dart';
import 'package:lottie/lottie.dart'; // Import Lottie for animations
import 'package:vibration/vibration.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _selectedOptionIndex = -1;
  int _score = 0;
  bool _answered = false;
  bool _isSpeaking = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    initTTS();
    initSpeech();
    _loadQuestions();
  }

  // Initialize Text-to-Speech
  Future<void> initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  // Initialize Speech-to-Text
  Future<void> initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final questions = (prefs.getStringList('questions') ?? []).map((q) {
      final parts = q.split('|');
      return Question(
        text: parts[0],
        options: parts.sublist(1, 5),
        correctOption: int.parse(parts[5]),
      );
    }).toList();

    setState(() {
      _questions = questions;
    });

    // Ensure TTS is ready before calling the function
    await initTTS(); // Make sure TTS is ready
    if (_questions.isNotEmpty) {
      await _readQuestion(); // Read the question aloud
    }
  }

  // Read the current question aloud
  Future<void> _readQuestion() async {
    if (_questions.isEmpty) return;
    final question = _questions[_currentQuestionIndex];
    await _speakText(question.text);
    await Future.delayed(const Duration(milliseconds: 500));
    _readOptions();
  }

  // Read all options aloud
  Future<void> _readOptions() async {
    if (_questions.isEmpty) return;
    final question = _questions[_currentQuestionIndex];
    for (int i = 0; i < question.options.length; i++) {
      await _speakText("Option ${i + 1} is ${question.options[i]}");
    }
    setState(() {
      _answered = false;
    });
  }

  // Speak the provided text
  Future<void> _speakText(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(text);
      while (_isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  // Handle voice input
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

  // Process the recognized speech result
  // Process the recognized speech result
  void _onSpeechResult(SpeechRecognitionResult result) {
    final userAnswer = result.recognizedWords.toLowerCase().trim();
    print('Recognized Words: $userAnswer'); // Debugging line

    // Add synonyms for "next question"
    if (userAnswer.contains('next') ||
        userAnswer.contains('next question') ||
        userAnswer.contains('skip') ||
        userAnswer.contains('go forward') ||
        userAnswer.contains('continue')) {
      _nextQuestion();

      // Add synonyms for "previous question"
    } else if (userAnswer.contains('previous') ||
        userAnswer.contains('previous question') ||
        userAnswer.contains('go back') ||
        userAnswer.contains('backward') ||
        userAnswer.contains('last question')) {
      _previousQuestion();

      // Add synonyms for "repeat question"
    } else if (userAnswer.contains('repeat question') ||
        userAnswer.contains('say it again') ||
        userAnswer.contains('repeat')) {
      _replayQuestion(); // Replay the question

      // Check if the command includes a specific option number
    } else if (userAnswer.contains('repeat question') ||
        userAnswer.contains('say it again') ||
        userAnswer.contains('repeat')) {
      _replayQuestion(); // Replay the question

      // Replay the options
      for (int i = 0;
          i < _questions[_currentQuestionIndex].options.length;
          i++) {
        _flutterTts.speak(
            'Option ${i + 1}: ${_questions[_currentQuestionIndex].options[i]}');
      }
    }
    // for selecting option
    else {
      final optionIndex = _parseOption(userAnswer);
      if (optionIndex != null &&
          optionIndex >= 0 &&
          optionIndex < _questions[_currentQuestionIndex].options.length) {
        _onOptionSelected(optionIndex);
      } else {
        _flutterTts.speak("I did not recognize your command.");
      }
    }
  }

  // Convert common answer phrases to option index
  int? _parseOption(String answer) {
    // Extend the optionMapping to include multiple variations of the same command
    final Map<String, int> optionMapping = {
      'option one': 0,
      'first option': 0,
      '1': 0,
      'one': 0, // Handle just saying 'one'

      'option two': 1,
      'second option': 1,
      '2': 1,
      'two': 1, // Handle just saying 'two'

      'option three': 2,
      'third option': 2,
      '3': 2,
      'three': 2, // Handle just saying 'three'

      'option four': 3,
      'fourth option': 3,
      '4': 3,
      'four': 3, // Handle just saying 'four'
    };

    // Normalize the recognized speech: lowercase and trim extra spaces
    final normalizedAnswer =
        answer.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

    // Return the matched option index
    return optionMapping[normalizedAnswer];
  }

  // Select option and auto-move to the next question after delay
  void _onOptionSelected(int index) {
    if (!_answered) {
      setState(() {
        _selectedOptionIndex = index;
        _answered = true;
        _isCorrect = index == _questions[_currentQuestionIndex].correctOption;
        if (_isCorrect) {
          _score++;
        } else {
          // Trigger vibration feedback for incorrect answer
          Vibration.vibrate(duration: 500); // Vibrate for 500 milliseconds
        }
      });
      _flutterTts.speak(_isCorrect ? "Correct" : "Incorrect Answer");

      // Auto-move to the next question after a delay of 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _nextQuestion();
      });
    }
  }

  // Move to next question
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = -1;
        _answered = false;
        _readQuestion();
      });
    } else {
      _flutterTts.speak("Quiz completed. Thank you for participating.");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultsPage(score: _score, totalQuestions: _questions.length),
        ),
      );
    }
  }

  // Move to previous question
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOptionIndex = -1;
        _answered = false;
        _readQuestion();
      });
    } else {
      _flutterTts.speak("This is the first question.");
    }
  }

  // Replay the current question
  void _replayQuestion() {
    if (_questions.isNotEmpty) {
      final question = _questions[_currentQuestionIndex];
      _speakText(question.text);
    }
  }

  // Replay a specific option
  void _replayOption(int index) {
    if (_questions.isNotEmpty && index >= 0 && index < 4) {
      final option = _questions[_currentQuestionIndex].options[index];
      _speakText("Option ${index + 1} is ${option}");
    }
  }

  // Check answer by button click
  void _checkAnswer() {
    if (_selectedOptionIndex != -1) {
      final question = _questions[_currentQuestionIndex];
      setState(() {
        _answered = true;
        _isCorrect = _selectedOptionIndex == question.correctOption;
        if (_isCorrect) {
          _score++;
        }
      });
      _flutterTts.speak(_isCorrect ? "Correct" : "Incorrect Answer");

      // Auto-move to the next question after a delay of 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _nextQuestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadQuestions();
            },
          ),
        ],
      ),
      body: _questions.isEmpty
          ? Center(
              child: Text(
                'Loading questions...',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex:
                      2, // Adjust flex to control space allocated to quiz content
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _questions[_currentQuestionIndex].text,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 1),
                        ...List.generate(
                          4,
                          (index) => RadioListTile<int>(
                            title: Text(
                              _questions[_currentQuestionIndex].options[index],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            value: index,
                            groupValue: _selectedOptionIndex,
                            onChanged: (value) {
                              setState(() {
                                _selectedOptionIndex = value!;
                              });
                            },
                            tileColor: _selectedOptionIndex == index
                                ? Colors.blue.shade100
                                : Colors.transparent,
                          ),
                        ),
                        const SizedBox(height: 1),
                        ElevatedButton(
                          onPressed: _answered ? _nextQuestion : _checkAnswer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _answered ? 'Next Question' : 'Submit Answer',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_answered)
                          Text(
                            _isCorrect ? 'Correct!' : 'Incorrect!',
                            style: TextStyle(
                              color: _isCorrect ? Colors.green : Colors.red,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
                // Updated voice input section with increased height
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onLongPress: _startListening,
                    onLongPressUp: _stopListening,
                    child: Container(
                      width: double.infinity,
                      height: 500,
                      color: Colors.white,
                      child: Center(
                        child: _isListening
                            ? Lottie.network(
                                'https://lottie.host/d6546831-1930-48d4-9e82-70fa2aeca5f9/8kIDv5qgMv.json',
                                width: 300,
                                height: 300,
                              )
                            : const Icon(
                                Icons.mic_none,
                                size: 80,
                                color: Color.fromARGB(255, 1, 197,
                                    24), // Changed the color to match the home page design
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// Question class to represent quiz questions
class Question {
  final String text;
  final List<String> options;
  final int correctOption;

  Question({
    required this.text,
    required this.options,
    required this.correctOption,
  });
}
