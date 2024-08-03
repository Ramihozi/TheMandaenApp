import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'community_add_post_screen.dart';
import 'community_chat_screen.dart';
import 'community_home_screen.dart';
import 'community_profile.dart';

class MainScreenController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxInt unreadMessagesCount = 0.obs; // Observable for unread messages count

  final widgetOptions = [
    HomeScreen(),
    AddPostScreen(),
    const CommunityChatScreen(),
    ProfileScreen(userId: null,)
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _listenToUnreadMessages();
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  void _listenToUnreadMessages() {
    String currentUserId = _auth.currentUser!.uid;

    _firestore.collection('messages')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      int count = 0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        bool isRead = data['isRead'][currentUserId] ?? true;

        if (!isRead) {
          count++;
        }
      }

      unreadMessagesCount.value = count;
    });
  }
}
