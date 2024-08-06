import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String text;
  final Timestamp timestamp;
  final String? storyUrl;
  final Map<String, bool> isRead; // New field to track read status

  Message({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.storyUrl,
    required this.isRead, // Include isRead in the constructor
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Unknown',
      text: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      storyUrl: map['storyUrl'],
      isRead: Map<String, bool>.from(map['isRead'] ?? {}), // Default to an empty map if not present
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': text, // Fixed typo: use 'text' instead of 'message'
      'timestamp': timestamp,
      'storyUrl': storyUrl,
      'isRead': isRead, // Include isRead in the map
    };
  }
}
