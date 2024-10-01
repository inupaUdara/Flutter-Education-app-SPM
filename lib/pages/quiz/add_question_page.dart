import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _correctOption = 0;
  List<Question> _questions = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final questionStrings = prefs.getStringList('questions') ?? [];

    setState(() {
      _questions = questionStrings.map((q) {
        final parts = q.split('|');
        return Question(
          text: parts[0],
          options: parts.sublist(1, 5),
          correctOption: int.parse(parts[5]),
        );
      }).toList();
    });
  }

  Future<void> _addQuestion() async {
    final questionText = _questionController.text;
    final options =
        _optionControllers.map((controller) => controller.text).toList();
    final correctOption = _correctOption;

    // Check if the question and all options are filled
    if (questionText.isEmpty) {
      _showAlertDialog('Please enter a question.');
      return;
    }

    if (options.any((option) => option.isEmpty) || options.length < 4) {
      _showAlertDialog(
          'Please provide all 4 options before adding the question.');
      return;
    }

    // If valid, proceed to add the question
    final question = Question(
      text: questionText,
      options: options,
      correctOption: correctOption,
    );

    final prefs = await SharedPreferences.getInstance();
    final questionStrings = prefs.getStringList('questions') ?? [];

    List<Question> questions = questionStrings.map((q) {
      final parts = q.split('|');
      return Question(
        text: parts[0],
        options: parts.sublist(1, 5),
        correctOption: int.parse(parts[5]),
      );
    }).toList();

    if (_editingIndex != null) {
      questions[_editingIndex!] = question;
    } else {
      questions.add(question);
    }

    await prefs.setStringList(
      'questions',
      questions
          .map((q) => '${q.text}|${q.options.join('|')}|${q.correctOption}')
          .toList(),
    );

    Navigator.pop(context, true);
    // Provide feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              _editingIndex != null ? 'Question updated' : 'Question added')),
    );
  }

  Future<void> _showAlertDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message), // The alert message
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _editQuestion(int index) {
    final question = _questions[index];
    _questionController.text = question.text;
    for (int i = 0; i < question.options.length; i++) {
      _optionControllers[i].text = question.options[i];
    }
    setState(() {
      _correctOption = question.correctOption;
      _editingIndex = index;
    });
  }

  Future<void> _deleteQuestion(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final questionStrings = prefs.getStringList('questions') ?? [];
    final questions = questionStrings.map((q) {
      final parts = q.split('|');
      return Question(
        text: parts[0],
        options: parts.sublist(1, 5),
        correctOption: int.parse(parts[5]),
      );
    }).toList();

    questions.removeAt(index);

    await prefs.setStringList(
      'questions',
      questions
          .map((q) => '${q.text}|${q.options.join('|')}|${q.correctOption}')
          .toList(),
    );

    setState(() {
      _questions.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question deleted')),
      );
    });
  }

  Future<void> _generatePdfReport() async {
    final pdf = pw.Document();

    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Question ${i + 1}: ${question.text}',
                  style: const pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 10),
              pw.Text('Options:', style: const pw.TextStyle(fontSize: 16)),
              ...List.generate(
                question.options.length,
                (index) => pw.Text(
                    '  Option ${index + 1}: ${question.options[index]}'),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Correct Option: Option ${question.correctOption + 1}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/questions_report.pdf');
      await file.writeAsBytes(await pdf.save());

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Generated'),
          content: Text('PDF report saved to ${file.path}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                OpenFile.open(file.path);
              },
              child: const Text('Open'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save PDF: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _generatePdfReport,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the row
                children: [
                  Icon(
                    Icons.question_answer, // Example icon
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8), // Space between icon and text
                  Text(
                    'Add/Edit Question',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 24, // Font size
                          fontWeight: FontWeight.bold, // Make the font bold
                          color: Theme.of(context)
                              .primaryColor, // Change color to primary theme color
                        ),
                    textAlign: TextAlign.center, // Center align the text
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //text field one
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  hintText: 'Type your question here',
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  helperText: 'Please enter a clear and concise question.',
                  errorText: _questionController.text.isEmpty
                      ? 'This field cannot be empty'
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(Icons.question_answer,
                      color: Theme.of(context).primaryColor),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),

              const SizedBox(height: 10), // Space before the Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: List.generate(4, (index) {
                      return Column(
                        children: [
                          TextField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          if (index < 3)
                            const SizedBox(
                                height:
                                    10), // Leave a gap except after the last TextField
                        ],
                      );
                    }),
                  ),
                ),
              ),

              DropdownButton<int>(
                value: _correctOption,
                items: List.generate(
                  4,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text('Correct answer ${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _correctOption = value;
                    });
                  }
                },
                hint: const Text('Select Correct Option'),
                isExpanded: true,
                underline: Container(
                  height: 2,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addQuestion,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  _editingIndex == null ? 'Add Question' : 'Update Question',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(
                          question.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(question.options.join(', ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editQuestion(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuestion(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
