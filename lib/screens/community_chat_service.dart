import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendMessage(String friendId, Map<String, dynamic> message) async {
    String currentUserId = _auth.currentUser!.uid;

    List<String> userIds = [currentUserId, friendId];
    userIds.sort();
    String chatId = userIds.join('_');

    DocumentReference chatDoc = _firestore.collection('messages').doc(chatId);

    List<String> blockedUsers = await _getBlockedUsers(friendId);
    if (blockedUsers.contains(currentUserId)) {
      await _addBlockedMessage(chatDoc, currentUserId, friendId, storyUrl: message['storyUrl']);
      print('You are blocked by this user. Message not sent.');
      return;
    }

    DocumentSnapshot chatSnapshot = await chatDoc.get();
    WriteBatch batch = _firestore.batch();

    if (!chatSnapshot.exists) {
      batch.set(chatDoc, {
        'participants': [currentUserId, friendId],
        'latestMessage': message['message'],
        'updatedAt': FieldValue.serverTimestamp(),
        'isRead': {
          currentUserId: true, // Current user’s messages are marked as read by default
          friendId: false,    // Recipient's messages are not read initially
        }
      });
    } else {
      batch.update(chatDoc, {
        'latestMessage': message['message'],
        'updatedAt': FieldValue.serverTimestamp(),
        'isRead.$friendId': false, // Set the recipient's read status to false
      });
    }

    DocumentReference messageDoc = chatDoc.collection('chats').doc();
    batch.set(messageDoc, {
      'senderId': currentUserId,
      'senderName': (await _firestore.collection('user').doc(currentUserId).get()).get('name') ?? 'Unknown',
      'message': message['message'],
      'storyUrl': message['storyUrl'], // Can be null if not a story reply
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': {
        currentUserId: true, // Mark the sender's own message as read
        friendId: false,    // Recipient's message is not read initially
      }
    });

    await batch.commit();
  }

  Future<void> _addBlockedMessage(DocumentReference chatDoc, String currentUserId, String friendId, {String? storyUrl}) async {
    WriteBatch batch = _firestore.batch();

    DocumentSnapshot chatSnapshot = await chatDoc.get();

    if (!chatSnapshot.exists) {
      batch.set(chatDoc, {
        'participants': [currentUserId, friendId],
        'latestMessage': 'You are blocked by this user.',
        'updatedAt': FieldValue.serverTimestamp(),
        'isRead': {
          currentUserId: true,
          friendId: false,
        }
      });
    } else {
      batch.update(chatDoc, {
        'latestMessage': 'You are blocked by this user.',
        'updatedAt': FieldValue.serverTimestamp(),
        'isRead.$friendId': false,
      });
    }

    DocumentReference messageDoc = chatDoc.collection('chats').doc();
    batch.set(messageDoc, {
      'senderId': currentUserId,
      'message': 'You are blocked by this user.',
      'storyUrl': storyUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': {
        currentUserId: true,
        friendId: false,
      }
    });

    await batch.commit();
  }

  Future<void> markMessagesAsSeen(String friendId) async {
    String currentUserId = _auth.currentUser!.uid;

    List<String> userIds = [currentUserId, friendId];
    userIds.sort();
    String chatId = userIds.join('_');

    DocumentReference chatDoc = _firestore.collection('messages').doc(chatId);

    // Update the isRead status for messages from the friend (recipient)
    QuerySnapshot querySnapshot = await chatDoc.collection('chats')
        .where('senderId', isEqualTo: friendId)
        .where('isRead.$currentUserId', isEqualTo: false)
        .get();

    WriteBatch batch = _firestore.batch();

    for (QueryDocumentSnapshot messageDoc in querySnapshot.docs) {
      batch.update(messageDoc.reference, {
        'isRead.$currentUserId': true,
      });
    }

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

    List<String> userIds = [currentUserId, friendId];
    userIds.sort();
    String chatId = userIds.join('_');

    DocumentReference chatDoc = _firestore.collection('messages').doc(chatId);

    CollectionReference messagesCollection = chatDoc.collection('chats');

    QuerySnapshot messagesSnapshot = await messagesCollection.get();

    WriteBatch batch = _firestore.batch();

    for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
      batch.delete(messageDoc.reference);
    }

    await batch.commit();
    print('Deleted all messages from blocked user');
  }
}
