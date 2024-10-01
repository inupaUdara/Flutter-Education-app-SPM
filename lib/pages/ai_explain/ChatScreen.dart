import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lottie/lottie.dart'; // Import Lottie for animation
import 'explain.dart'; // Import the ExplainPage
import 'chat_history_page.dart'; // Import the ChatHistoryPage

class ChatScreen extends StatefulWidget {
  final String identifiedObject; // Add identifiedObject as a parameter

  ChatScreen({required this.identifiedObject}); // Required constructor

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isTyping = false;
  bool _isSpeaking = false; // Variable to track speaking state

  // Initialize FlutterTTS instance
  FlutterTts _flutterTts = FlutterTts();
  List<Map> _voices = [];
  Map? _currentVoice;

  @override
  void initState() {
    super.initState();
    initTTS();
    // Automatically send the message when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendMessage();
    });
  }

  void initTTS() async {
    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        // Handle word highlighting if needed
      });
    });

    _flutterTts.setCompletionHandler(() {
      // Stop speaking animation once speech completes
      setState(() {
        _isSpeaking = false;
      });

      // Navigate to ExplainPage after speech ends
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ExplainPage(identifiedObject: widget.identifiedObject), // Pass the identified object to ExplainPage
        ),
      );
    });

    List<Map> voices = List<Map>.from(await _flutterTts.getVoices as List);
    setState(() {
      _voices = voices.where((voice) => voice["name"].contains("en")).toList();
      _currentVoice = _voices.first;
      setVoice(_currentVoice!);
    });

    // Set default TTS parameters
    await _flutterTts.setPitch(1.0); // Normal pitch
    await _flutterTts.setSpeechRate(0.5); // Slightly slower speech rate
    await _flutterTts.setVolume(1.0); // Maximum volume
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
  }

  Future<void> speak(String text) async {
    setState(() {
      _isSpeaking = true; // Start speaking animation
    });
    await _flutterTts.speak(text);
  }

  void sendMessage() async {
    String identifiedObject = widget.identifiedObject; // Use the passed identified object
    setState(() {
      isTyping = true;
      messages.add({'text': identifiedObject, 'sender': 'user'});
    });

    final String predefinedPrompt =
        "Provide a simple and short explanation of the identified item for a visually impaired student. "
        "The identified item is: $identifiedObject. Ensure the explanation is short and clear. Always start with 'This is'.";

    final content = [Content.text(predefinedPrompt)];
    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: "AIzaSyD6O2MQ5yKAtAhRwMuxjE3-mR5BE2W-rkY"); // Use your actual API key
    final response = await model.generateContent(content);

    setState(() {
      messages.add({'text': response.text!, 'sender': 'bot'});
      isTyping = false;
    });

    // Filter out unwanted characters like * / \n
    String filteredResponseText = response.text!
        .replaceAll('*', '')
        .replaceAll('/', '')
        .replaceAll('\n', ' '); // Replace newline with space

    // Speak the response text
    await speak(filteredResponseText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
    ' ${widget.identifiedObject}',
    style: TextStyle(color: Colors.white), // Set the text color to white
  ),
         // Show the identified object at the top
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatHistoryPage()),
              );
            },
            child: Text(
              "Chat history",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).colorScheme.primary : Colors.blueGrey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSpeaking) // Show animation while speaking
            Lottie.network(
              'https://lottie.host/0e504c43-7dae-4143-8ec4-622d1343fd4b/R88atFfg7q.json',
              width: 400,
              height: 400,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isTyping
                ? CircularProgressIndicator() // Show loading while typing
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}