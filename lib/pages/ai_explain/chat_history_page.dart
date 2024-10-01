import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'chat_data_store.dart';
import 'chat_message.dart';
import 'package:open_file/open_file.dart';


class ChatHistoryPage extends StatefulWidget {
  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  late Future<List<ChatMessage>> _chatHistoryFuture;

  @override
  void initState() {
    super.initState();
    _chatHistoryFuture = ChatDataStore.getChatHistory();
  }

  void _deleteChat(ChatMessage chatMessage) async {
    await ChatDataStore.deleteChat(chatMessage);
    setState(() {
      _chatHistoryFuture = ChatDataStore.getChatHistory();
    });
  }

  void _editChat(ChatMessage chatMessage) async {
    TextEditingController _editController =
        TextEditingController(text: chatMessage.message);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Chat Message'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(labelText: 'Edit your message'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                final editedMessage = ChatMessage(
                  message: _editController.text,
                  sender: chatMessage.sender,
                  timestamp: chatMessage.timestamp,
                );
                await ChatDataStore.editChat(chatMessage, editedMessage);
                setState(() {
                  _chatHistoryFuture = ChatDataStore.getChatHistory();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

 Future<void> _downloadChatHistoryAsPDF() async {
  final pdf = pw.Document();
  final chatHistory = await ChatDataStore.getChatHistory();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          pw.ListView.builder(
            itemCount: chatHistory.length,
            itemBuilder: (context, index) {
              final chatMessage = chatHistory[index];
              final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(chatMessage.timestamp.toLocal());
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      chatMessage.sender,
                      style: pw.TextStyle(fontSize: 18, color: PdfColors.blue),
                    ),
                    pw.Text(
                      chatMessage.message,
                      style: pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      formattedDate,
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                    pw.Divider(),
                  ],
                ),
              );
            },
          ),
        ];
      },
    ),
  );

  try {
    // Get the Downloads directory on Android
    final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Chat_report.pdf');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History',style: TextStyle(color: Colors.white),),
        
         backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadChatHistoryAsPDF,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
        backgroundColor: const Color.fromARGB(255, 233, 233, 233),
      body: FutureBuilder<List<ChatMessage>>(
        future: _chatHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading chat history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chat history available'));
          } else {
            final chatHistory = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chatMessage = chatHistory[index];
                Color messageColor;
                if (chatMessage.sender == 'User') {
                  messageColor = const Color.fromARGB(255, 0, 138, 5);
                } else if (chatMessage.sender == 'AI') {
                  messageColor = const Color.fromARGB(255, 0, 81, 147);
                } else {
                  messageColor = Colors.red;
                }

                return Card(
                  
                  margin: EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    
                    title: Text(
                      chatMessage.message,
                      style: TextStyle(color: messageColor, fontSize: 16),
                      
                    ),
                    subtitle: Text(
                      '${chatMessage.sender} | ${DateFormat('yyyy-MM-dd HH:mm').format(chatMessage.timestamp.toLocal())}',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editChat(chatMessage),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteChat(chatMessage),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}