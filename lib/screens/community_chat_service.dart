import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendMessage(String friendId, String message) async {
    String currentUserId = _auth.currentUser!.uid;

    // Create a chat document ID based on the two user IDs to ensure uniqueness
    List<String> userIds = [currentUserId, friendId];
    userIds.sort(); // Sort to ensure uniqueness irrespective of the order of user IDs
    String chatId = userIds.join('_');

    // Get reference to the chat document
    DocumentReference chatDoc = _firestore.collection('messages').doc(chatId);

    // Check if the document already exists
    DocumentSnapshot chatSnapshot = await chatDoc.get();

    // Batch to perform multiple writes atomically
    WriteBatch batch = _firestore.batch();

    if (!chatSnapshot.exists) {
      // If the chat document does not exist, create it with initial data
      batch.set(chatDoc, {
        'participants': [currentUserId, friendId],
        'latestMessage': message,
        'updatedAt': FieldValue.serverTimestamp(), // Optional: To track the last update time
        'isRead': {
          currentUserId: true,
          friendId: false,
        }
      });
    } else {
      // If the chat document exists, update the latestMessage field
      batch.update(chatDoc, {
        'latestMessage': message,
        'updatedAt': FieldValue.serverTimestamp(), // Optional: To track the last update time
        'isRead.$friendId': false,
      });
    }

    // Add the message to a subcollection (e.g., 'chats') inside the chat document
    DocumentReference messageDoc = chatDoc.collection('chats').doc();
    batch.set(messageDoc, {
      'senderId': currentUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': {
        currentUserId: true,
        friendId: false,
      }
    });

    // Commit the batch
    await batch.commit();
  }

  Stream<QuerySnapshot> getChatMessagesStream(String friendId) {
    String currentUserId = _auth.currentUser!.uid;
    List<String> userIds = [currentUserId, friendId];
    userIds.sort();
    String chatId = userIds.join('_');

    return _firestore
        .collection('messages')
        .doc(chatId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
