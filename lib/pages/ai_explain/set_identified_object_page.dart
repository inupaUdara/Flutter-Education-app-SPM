// set_identified_object_page.dart
import 'package:flutter/material.dart';
import 'ChatScreen.dart';

class SetIdentifiedObjectPage extends StatefulWidget {
  @override
  _SetIdentifiedObjectPageState createState() => _SetIdentifiedObjectPageState();
}

class _SetIdentifiedObjectPageState extends State<SetIdentifiedObjectPage> {
  final TextEditingController _textController = TextEditingController();

  void handleSubmit() {
    if (_textController.text.isEmpty) return;
    String identifiedObject = _textController.text;

    // Navigate to ChatScreen and pass the identified object
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(identifiedObject: identifiedObject),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Identified Object'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Enter the Identified Object Name",
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleSubmit,
              child: Text('Go to Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}