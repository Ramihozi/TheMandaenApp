import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'community_post.dart'; // Assuming this is where your Post class is defined

class ProfileController extends GetxController {
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString url = ''.obs;
  User? user = FirebaseAuth.instance.currentUser;
  RxList<Post> posts = RxList<Post>();

  Future<void> getUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("user")
            .doc(user!.uid)
            .get();

        name.value = userDoc['name'] ?? '';
        email.value = userDoc['email'] ?? '';
        url.value = userDoc['url'] ?? '';
      } catch (e) {
        return;
      }
    }
  }

  Future<void> getUserPosts() async {
    if (user != null) {
      try {
        QuerySnapshot postDocs = await FirebaseFirestore.instance
            .collection("post")
            .where('userUid', isEqualTo: user!.uid)
            .get();

        posts.clear();
        for (DocumentSnapshot doc in postDocs.docs) {
          List<String> likes = List<String>.from(doc['likes'] ?? []);

          // Fetch comments for this post from 'comments' collection
          QuerySnapshot commentsQuery = await FirebaseFirestore.instance
              .collection("comment")
              .where('postId', isEqualTo: doc.id)
              .get();

          List<String> comments = commentsQuery.docs.map((commentDoc) => commentDoc['comment'].toString()).toList();

          posts.add(Post(
            postId: doc.id,
            postTitle: doc['postTitle'] ?? '',
            postUrl: doc['postUrl'] ?? '',
            comments: comments,
            likes: likes,
            userName: doc['userName'] ?? '',
            userUid: doc['userUid'] ?? '',
            userUrl: doc['userUrl'] ?? '',
            time: doc['time'] ?? 0,
            commentsCount: comments.length, // Update commentsCount based on fetched comments
          ));
        }
      } catch (e) {
        return;
      }
    }
  }

  @override
  void onInit() async {
    await getUserData();
    await getUserPosts();
    super.onInit();
  }
}
