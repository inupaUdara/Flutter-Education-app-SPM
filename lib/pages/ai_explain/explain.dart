import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'chat_data_store.dart';
import 'chat_message.dart';
import 'chat_history_page.dart';
import 'package:lottie/lottie.dart';

class ExplainPage extends StatefulWidget {
  final String identifiedObject;

  ExplainPage({required this.identifiedObject});

  @override
  _ExplainPageState createState() => _ExplainPageState();
}

class _ExplainPageState extends State<ExplainPage> {
  final TextEditingController _questionController = TextEditingController();
  String responseText = "";
  bool isLoading = false;
  late FlutterTts _flutterTts;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  bool _isButtonPressed = false;
  List<ChatMessage> chatHistory = [];
  bool _isListening = false; // Track if it's listening
  bool _isSpeaking = false; // Track if it's speaking

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    initTTS();
    initSpeech();

    // Save identified object at the start of the chat
    saveChatMessage(
        'Identified object is: ${widget.identifiedObject}', 'System');
  }

  void initTTS() {
    _flutterTts.setCompletionHandler(() {
      setState(() {});
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
    });
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void askMoreQuestions(String question) async {
    if (question.isEmpty) return;

    setState(() {
      isLoading = true;
      chatHistory.add(ChatMessage(
        message: question,
        sender: 'User',
        timestamp: DateTime.now(),
      ));
    });

    saveChatMessage(question, 'User');

    final String predefinedPrompt =
        "You are answering additional questions about an identified item for a visually impaired student. "
        "The identified item is: ${widget.identifiedObject}. The question is: $question. "
        "Provide a detailed and clear response suitable for text-to-speech. Don't use any symbols in the text output, just plain text.";

    final content = [Content.text(predefinedPrompt)];
    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: "AIzaSyD6O2MQ5yKAtAhRwMuxjE3-mR5BE2W-rkY");
    final response = await model.generateContent(content);

    String filteredResponseText = response.text!
        .replaceAll('*', '')
        .replaceAll('/', '')
        .replaceAll('\n', ' ');

    setState(() {
      responseText = filteredResponseText;
      isLoading = false;
      chatHistory.add(ChatMessage(
        message: responseText,
        sender: 'AI',
        timestamp: DateTime.now(),
      ));
    });

    saveChatMessage(responseText, 'AI');

    await _flutterTts.speak(responseText);
  }

  void saveChatMessage(String message, String sender) {
    ChatDataStore.saveChat(ChatMessage(
      message: message,
      sender: sender,
      timestamp: DateTime.now(),
    ));
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isButtonPressed = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isButtonPressed = false;
      _questionController.text = _wordsSpoken;
    });
    if (_wordsSpoken.isNotEmpty) {
      askMoreQuestions(_wordsSpoken);
    }
  }

  void _onSpeechResult(result) {
    setState(() {
      _isSpeaking = true;
      _wordsSpoken = result.recognizedWords;
      _questionController.text = _wordsSpoken;
      _confidenceLevel = result.confidence;
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false; // Stop speaking animation
      });
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Ask About ${widget.identifiedObject}'),
      backgroundColor: Colors.blueAccent, // AppBar background color
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatHistoryPage()),
            );
          },
          child: Text(
            "Chat History",
            style: TextStyle(color: Colors.white), // Text color for visibility
          ),
        ),
      ],
    ),
    backgroundColor: Colors.white, // Set the background color of the Scaffold
    body: Column(
      children: [
        // Top half of the screen: text input and buttons
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Wrap the response text in a Flexible widget to avoid overflow
                if (responseText.isNotEmpty)
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        '$responseText',
                        style: TextStyle(fontSize: 16, color: Colors.black87), // Text color
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                TextField(
                  controller: _questionController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Ask a question...',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 53, 145)), // Label text color
                    
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
  visible: !isLoading, // Hide the button when isLoading is true
  child: ElevatedButton(
    onPressed: () => askMoreQuestions(_questionController.text),
    child: Text('Submit', style: TextStyle(color: Colors.white)), // Text color
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 34, 111, 244), // Button background color
    ),
  ),
),
              ],
            ),
          ),
        ),
        // Bottom half of the screen: Gesture area for voice input
        Expanded(
          flex: 1,
          child: GestureDetector(
            onLongPress: () {
              _flutterTts.stop(); // Stop the speech output
              _startListening(); // Start listening for user input
              setState(() {
                _isListening = true; // Listening animation starts
                _isSpeaking = false; // Ensure no speaking animation is active
              });
            },
            onLongPressUp: () {
              _stopListening();
              setState(() {
                _isListening = false;
              });
            },
            child: Container(
              width: double.infinity,
              color: Colors.white, // Container background color
              child: Center(
                child: isLoading
                    ? Lottie.network(
                        'https://lottie.host/cc40834c-0b0e-4758-827e-06de2767ade5/2pNpN1FN8o.json', // Loading animation
                        width: 200,
                        height: 200,
                      )
                    : _isListening
                        ? Lottie.network(
                            'https://lottie.host/d6546831-1930-48d4-9e82-70fa2aeca5f9/8kIDv5qgMv.json', // Listening animation
                            width: 300,
                            height: 300,
                          )
                        : (_isSpeaking
                            ? Lottie.network(
                                'https://lottie.host/0e504c43-7dae-4143-8ec4-622d1343fd4b/R88atFfg7q.json', // Speaking animation
                                width: 400,
                                height: 400,
                              )
                            : Icon(
                                Icons.mic_none,
                                size: 80,
                                color: const Color.fromARGB(255, 1, 197, 24), // Icon color
                              )),
              ),
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: _buildFloatingActionButtons(),
  );
}

  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: 14),
        if (responseText.isNotEmpty)
          FloatingActionButton(
            onPressed: () => _flutterTts.speak(responseText),
            backgroundColor: Colors.blueAccent, // Set background color
            foregroundColor: Colors.white, // Icon color
            child: Icon(Icons.replay),
          ),
        SizedBox(width: 14),
        FloatingActionButton(
          onPressed: () {
            _flutterTts.stop();
            setState(() {
              _isSpeaking =
                  false; // Stop speaking animation when TTS is stopped
            });
          },
          backgroundColor: Colors.red, // Set background color
          foregroundColor: Colors.white, // Icon color
          child: Icon(Icons.stop),
        ),
      ],
    );
  }
}
