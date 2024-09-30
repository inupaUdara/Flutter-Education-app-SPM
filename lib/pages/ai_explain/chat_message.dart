import 'dart:convert';

class ChatMessage {
  final String message;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.sender,
    required this.timestamp,
  });

  // Convert ChatMessage to a map
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a ChatMessage from a map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'],
      sender: map['sender'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}