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

    // Check if the friendId is blocked by the currentUserId
    List<String> blockedUsers = await _getBlockedUsers(friendId);
    if (blockedUsers.contains(currentUserId)) {
      // Add a message indicating the current user is blocked by the friend
      await _addBlockedMessage(chatDoc, currentUserId, friendId);
      print('You are blocked by this user. Message not sent.');
      return;
    }

    // Check if the chat document already exists
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

  Future<void> _addBlockedMessage(DocumentReference chatDoc, String currentUserId, String friendId) async {
    WriteBatch batch = _firestore.batch();

    // Check if the chat document already exists
    DocumentSnapshot chatSnapshot = await chatDoc.get();

    if (!chatSnapshot.exists) {
      // If the chat document does not exist, create it with initial data
      batch.set(chatDoc, {
        'participants': [currentUserId, friendId],
        'latestMessage': 'You are blocked by this user.',
        'updatedAt': FieldValue.serverTimestamp(), // Optional: To track the last update time
        'isRead': {
          currentUserId: true,
          friendId: false,
        }
      });
    } else {
      // If the chat document exists, update the latestMessage field
      batch.update(chatDoc, {
        'latestMessage': 'You are blocked by this user.',
        'updatedAt': FieldValue.serverTimestamp(), // Optional: To track the last update time
        'isRead.$friendId': false,
      });
    }

    // Add the blocked message to a subcollection (e.g., 'chats') inside the chat document
    DocumentReference messageDoc = chatDoc.collection('chats').doc();
    batch.set(messageDoc, {
      'senderId': currentUserId,
      'message': 'You are blocked by this user.',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': {
        currentUserId: true,
        friendId: false,
      }
    });

    // Commit the batch
    await batch.commit();
  }

  Future<List<String>> _getBlockedUsers(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('user').doc(userId).get();
    return List<String>.from(userDoc['blockedUsers'] ?? []);
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

  Future<void> deleteBlockedMessages(String friendId) async {
    String currentUserId = _auth.currentUser!.uid;

    // Create a chat document ID based on the two user IDs to ensure uniqueness
    List<String> userIds = [currentUserId, friendId];
    userIds.sort(); // Sort to ensure uniqueness irrespective of the order of user IDs
    String chatId = userIds.join('_');

    // Get reference to the chat document
    DocumentReference chatDoc = _firestore.collection('messages').doc(chatId);

    // Get the messages subcollection
    CollectionReference messagesCollection = chatDoc.collection('chats');

    // Get all messages
    QuerySnapshot messagesSnapshot = await messagesCollection.get();

    // Batch to perform multiple deletes atomically
    WriteBatch batch = _firestore.batch();

    for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
      batch.delete(messageDoc.reference);
    }

    // Commit the batch
    await batch.commit();
    print('Deleted all messages from blocked user');
  }
}
