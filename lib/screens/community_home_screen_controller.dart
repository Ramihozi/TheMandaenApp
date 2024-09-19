import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'community_post.dart'; // Import your Post class

class HomeController extends GetxController {
  final _postList = RxList<Post>([]);
  List<Post> get posts => _postList;

  final _postsCollection = FirebaseFirestore.instance.collection("post");
  final _commentsCollection = FirebaseFirestore.instance.collection("comment");
  final _reportsCollection = FirebaseFirestore.instance.collection("report");
  final _usersCollection = FirebaseFirestore.instance.collection("user");
  final user = FirebaseAuth.instance.currentUser;
  final RxList<SuggestedFriend> suggestedFriends = <SuggestedFriend>[].obs;

  @override
  void onInit() {
    super.onInit();
    _postList.bindStream(getPosts());
    fetchSuggestedFriends();
  }

  Future<List<SuggestedFriend>> getAllUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return SuggestedFriend(
          id: doc.id, // Assuming doc.id contains the user's ID
          name: data['name'] ?? '',
          url: data['url'] ?? '',
        );
      }).toList();
      return users;
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  void fetchSuggestedFriends() async {
    try {
      final allUsers = await getAllUsers(); // Fetch all users
      final random = Random();
      final suggestedFriendsList = List<SuggestedFriend>.from(allUsers)..shuffle();
      final maxSuggestedFriends = 100;
      suggestedFriends.value = suggestedFriendsList.take(maxSuggestedFriends).toList();
    } catch (e) {
      print('Error fetching suggested friends: $e');
    }
  }

  Stream<List<Post>> getPosts() async* {
    final reportedPostIds = await _getReportedPostIds();
    final blockedUserIds = await _getBlockedUserIds(); // Fetch blocked users

    yield* _postsCollection
        .orderBy("time", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => !reportedPostIds.contains(doc.id) && !blockedUserIds.contains(doc['userUid'])) // Filter reported and blocked users' posts
          .map((doc) => Post.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  Future<List<String>> _getReportedPostIds() async {
    try {
      final reportsSnapshot = await _reportsCollection
          .where('reportedBy', isEqualTo: user!.uid)
          .get();

      return reportsSnapshot.docs.map((doc) => doc['postId'] as String).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reported post IDs: $e');
      }
      return [];
    }
  }

  Future<List<String>> _getBlockedUserIds() async {
    try {
      final userDoc = await _usersCollection.doc(user!.uid).get();
      return List<String>.from(userDoc['blockedUsers'] ?? []);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching blocked user IDs: $e');
      }
      return [];
    }
  }

  Future<void> setLike(String postId) async {
    try {
      DocumentSnapshot doc = await _postsCollection.doc(postId).get();

      if ((doc.data() as dynamic)['likes'].contains(user!.uid)) {
        await _postsCollection.doc(postId).update({
          "likes": FieldValue.arrayRemove([user!.uid]),
        });
      } else {
        await _postsCollection.doc(postId).update({
          "likes": FieldValue.arrayUnion([user!.uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error setting like: $e");
      }
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      QuerySnapshot likesQuery = await _postsCollection.doc(postId).collection('likes').get();
      for (DocumentSnapshot likeDoc in likesQuery.docs) {
        batch.delete(likeDoc.reference);
      }

      QuerySnapshot commentsQuery = await _commentsCollection.where('postId', isEqualTo: postId).get();
      for (DocumentSnapshot commentDoc in commentsQuery.docs) {
        batch.delete(commentDoc.reference);
      }

      batch.delete(_postsCollection.doc(postId));
      await batch.commit();

      _postList.removeWhere((post) => post.postId == postId);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting post: $e');
      }
      rethrow;
    }
  }

  Future<void> reportPost(String postId) async {
    try {
      await _reportsCollection.add({
        'postId': postId,
        'reportedBy': user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _postList.refresh(); // Trigger an update by fetching the latest list of posts
    } catch (e) {
      if (kDebugMode) {
        print('Error reporting post: $e');
      }
      rethrow;
    }
  }
}

class SuggestedFriend {
  final String id;
  final String name;
  final String url;

  SuggestedFriend({
    required this.id,
    required this.name,
    required this.url,
  });
}
