import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'community_post.dart'; // Import your Post class

class HomeController extends GetxController {
  final _postList = RxList<Post>([]);
  List<Post> get posts => _postList.value;

  final _postsCollection = FirebaseFirestore.instance.collection("post");
  final _commentsCollection = FirebaseFirestore.instance.collection("comment");
  final user = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    // Bind the stream to _postList
    _postList.bindStream(getPosts());
  }

  Stream<List<Post>> getPosts() {
    return _postsCollection
        .orderBy("time", descending: true)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((doc) => Post.fromDocumentSnapshot(doc)).toList();
    });
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
      print("Error setting like: $e");
      rethrow; // Rethrow the exception for handling in UI if needed
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      // Use batch operations for deleting associated likes and comments
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete likes associated with the post
      QuerySnapshot likesQuery = await _postsCollection.doc(postId).collection('likes').get();
      for (DocumentSnapshot likeDoc in likesQuery.docs) {
        batch.delete(likeDoc.reference);
      }

      // Delete comments associated with the post from 'comments' collection
      QuerySnapshot commentsQuery = await _commentsCollection.where('postId', isEqualTo: postId).get();
      for (DocumentSnapshot commentDoc in commentsQuery.docs) {
        batch.delete(commentDoc.reference);
      }

      // Delete the post itself
      batch.delete(_postsCollection.doc(postId));

      // Commit the batch
      await batch.commit();

      // Optionally, update local state if needed
      _postList.removeWhere((post) => post.postId == postId);
    } catch (e) {
      print('Error deleting post: $e');
      rethrow; // Rethrow the exception for handling in UI if needed
    }
  }
}
