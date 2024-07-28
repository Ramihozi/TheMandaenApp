import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_mandean_app/screens/user.dart';

class FirebaseService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('user');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseService() {
    _setupBlockUserListener();
  }

  // Real-time stream for getting users
  Stream<List<User>> getUsersStream(String currentUserId) {
    return usersCollection.snapshots().asyncMap((snapshot) async {
      List<User> users = snapshot.docs.map((doc) => User.fromSnapshot(doc)).toList();
      List<String> blockedUsers = await getBlockedUsers(currentUserId);

      // Filter out blocked users
      users.removeWhere((user) => blockedUsers.contains(user.id));

      return users;
    });
  }

  Future<List<String>> getBlockedUsers(String currentUserId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(currentUserId).get();
      if (doc.exists) {
        User user = User.fromSnapshot(doc);
        return user.blockedUsers;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching blocked users: $e');
      return [];
    }
  }

  Future<void> blockUser(String userId, String currentUserId) async {
    try {
      DocumentReference currentUserRef = usersCollection.doc(currentUserId);

      // Fetch the current user's document
      DocumentSnapshot currentUserDoc = await currentUserRef.get();

      // If the document does not exist, create it with default values
      if (!currentUserDoc.exists) {
        await currentUserRef.set({
          'name': '',
          'url': '',
          'blockedUsers': []
        });
      }

      // Update the blockedUsers field
      await currentUserRef.update({
        'blockedUsers': FieldValue.arrayUnion([userId])
      });

      // Optionally remove the blocked user from friends list
      await _removeFromFriendsList(userId, currentUserId);

      // Delete the message collection between the users
      await _deleteMessageCollection(userId, currentUserId);

      print('User blocked successfully');
    } catch (e) {
      print('Error blocking user: $e');
      throw e;
    }
  }

  Future<void> _removeFromFriendsList(String userId, String currentUserId) async {
    try {
      // Example: Assuming you have a subcollection 'friends' with a document per friend
      CollectionReference friendsCollection = usersCollection.doc(currentUserId).collection('friends');

      QuerySnapshot friendsSnapshot = await friendsCollection.get();
      for (DocumentSnapshot doc in friendsSnapshot.docs) {
        if (doc.id == userId) {
          await doc.reference.delete(); // Remove friend document
        }
      }

      print('Removed blocked user from friends list');
    } catch (e) {
      print('Error removing user from friends list: $e');
    }
  }

  Future<void> _deleteMessageCollection(String userId, String currentUserId) async {
    try {
      // Assuming the message collections are named in a consistent way, e.g., by concatenating user IDs
      String chatId = currentUserId.compareTo(userId) < 0
          ? '$currentUserId-$userId'
          : '$userId-$currentUserId';

      CollectionReference messagesCollection = _firestore.collection('messages').doc(chatId).collection('chat');

      QuerySnapshot messagesSnapshot = await messagesCollection.get();
      for (DocumentSnapshot doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      print('Deleted message collection between $currentUserId and $userId');
    } catch (e) {
      print('Error deleting message collection: $e');
    }
  }

  void _setupBlockUserListener() {
    usersCollection.snapshots().listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          User modifiedUser = User.fromSnapshot(change.doc);
          List<String> blockedUsers = await getBlockedUsers(modifiedUser.id);

          // Fetch current user's blocked users before the update
          DocumentSnapshot currentUserDoc = await usersCollection.doc(modifiedUser.id).get();
          if (currentUserDoc.exists) {
            User currentUser = User.fromSnapshot(currentUserDoc);

            // Check for newly blocked users
            for (String blockedUserId in blockedUsers) {
              if (!currentUser.blockedUsers.contains(blockedUserId)) {
                // New block detected, delete the message collection
                await _deleteMessageCollection(blockedUserId, modifiedUser.id);
              }
            }
          }
        }
      }
    });
  }
}
