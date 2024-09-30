import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_message.dart';

class ChatDataStore {
  static const String _chatHistoryKey = 'chatHistory';

  static Future<void> saveChat(ChatMessage chatMessage) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> chatHistory = prefs.getStringList(_chatHistoryKey) ?? [];
    chatHistory.add(json.encode(chatMessage.toMap()));
    await prefs.setStringList(_chatHistoryKey, chatHistory);
  }

  static Future<List<ChatMessage>> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> chatHistory = prefs.getStringList(_chatHistoryKey) ?? [];
    return chatHistory.map((chat) => ChatMessage.fromMap(json.decode(chat))).toList();
  }

  static Future<void> deleteChat(ChatMessage chatMessage) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> chatHistory = prefs.getStringList(_chatHistoryKey) ?? [];
    chatHistory.removeWhere((chat) => chat == json.encode(chatMessage.toMap()));
    await prefs.setStringList(_chatHistoryKey, chatHistory);
  }

  static Future<void> editChat(ChatMessage oldChat, ChatMessage newChat) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> chatHistory = prefs.getStringList(_chatHistoryKey) ?? [];
    final updatedChatHistory = chatHistory.map((chat) {
      final decodedChat = ChatMessage.fromMap(json.decode(chat));
      if (decodedChat.timestamp == oldChat.timestamp && decodedChat.sender == oldChat.sender) {
        return json.encode(newChat.toMap());
      }
      return chat;
    }).toList();
    await prefs.setStringList(_chatHistoryKey, updatedChatHistory);
  }
}