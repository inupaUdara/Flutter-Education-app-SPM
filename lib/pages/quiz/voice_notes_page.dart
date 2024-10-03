import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:spm_project/pages/home.dart'; // Import Lottie for animations

class VoiceNotesPage extends StatefulWidget {
  const VoiceNotesPage({super.key});

  @override
  State<VoiceNotesPage> createState() => _VoiceNotesPageState();
}

class _VoiceNotesPageState extends State<VoiceNotesPage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _voiceNote = "";
  List<String> _savedNotes = [];
  bool isLoading = false;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeech();
    initTTS();
    _loadNotes();
  }

  Future<void> initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  Future<void> initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedNotes = prefs.getStringList('voice_notes') ?? [];
    });
  }

  Future<void> _saveNote() async {
    if (_voiceNote.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedNotes.add(_voiceNote);
        _voiceNote = "";
        _textController.clear();
      });
      await prefs.setStringList('voice_notes', _savedNotes);

      Clipboard.setData(const ClipboardData(text: ""));
    }
  }

  Future<void> _playNoteAtIndex(int index) async {
    await _flutterTts.speak(_savedNotes[index]);
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _voiceNote = result.recognizedWords;
            _textController.text = _voiceNote;

            // Check if the recognized command is "back to home"
            if (_voiceNote.toLowerCase().contains('back to home')) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            }
          });
        },
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    if (_voiceNote.isNotEmpty) {
      _saveNote();
    }
    setState(() {
      _isListening = false;
    });
  }

  void _deleteNoteAtIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedNotes.removeAt(index);
    });
    await prefs.setStringList('voice_notes', _savedNotes);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Notes'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _savedNotes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_savedNotes[index]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  _playNoteAtIndex(index);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteNoteAtIndex(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Enter your voice note',
                          ),
                          controller: _textController,
                          onChanged: (value) {
                            setState(() {
                              _voiceNote = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onLongPress: () {
                _startListening();
                setState(() {
                  _isListening = true;
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
                color: Colors.white,
                child: Center(
                  child: _isListening
                      ? Lottie.network(
                          'https://lottie.host/d6546831-1930-48d4-9e82-70fa2aeca5f9/8kIDv5qgMv.json', // Listening animation
                          width: 300,
                          height: 300,
                        )
                      : const Icon(
                          Icons.mic_none,
                          size: 80,
                          color:
                              Color.fromARGB(255, 1, 197, 24), // Mic icon color
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
