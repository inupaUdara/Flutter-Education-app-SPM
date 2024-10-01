import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<String> voiceCommands = [
    "Home - Go to Home Screen",
    "Profile - Go to Profile ",
    "Help - Go to Help Screen",
    "Mathematics - Navigating to Maths Object Page",
    "Science - Navigating to Science Object Page",
    "Currency - Navigating to Currency Object Page",
    "Save - Navigating to Object Save Page",
    "Capture - Capturing the image",
    "Logout - Logout from the account",
  ];

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Voice Navigation Commands',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            ...voiceCommands
                .map((command) => pw.Bullet(text: command))
                .toList(),
          ],
        ),
      ),
    );

    // Get the path to save the file
    final directory = await getExternalStorageDirectory();
    final path = "${directory!.parent.parent.parent.parent.path}/Download";

    // Save the PDF file
    final file = File('$path/voice_command.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chat history saved as PDF at ${file.path}')),
    );

    // Print the PDF (allows viewing and saving as a PDF file)
    // await Printing.sharePdf(bytes: await pdf.save(), filename: 'VoiceCommands.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help",
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to LearnMate",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F276F)),
              ),
              const SizedBox(height: 16),
              const Text(
                "This app includes the following features:",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              _buildFeatureDescription("Voice Navigation",
                  "Use voice commands to navigate throughout the app."),
              _buildFeatureDescription("Object Detection",
                  "Detect objects using your device's camera with AI."),
              _buildFeatureDescription("AI Chat Bot",
                  "Interact with an AI-powered chatbot for instant help."),
              _buildFeatureDescription("Quiz",
                  "Test your knowledge through various quizzes available in the app."),
              const SizedBox(height: 20),
              const Text(
                "Voice Navigation Commands:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // _buildCommandList(),
              const Text(
                "Please click on the download button to view voice command",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Download Commands as PDF"),
                  onPressed: _generatePdf,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureDescription(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: voiceCommands
          .map(
            (command) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.mic, size: 20),
                  const SizedBox(width: 8),
                  Text(command, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
