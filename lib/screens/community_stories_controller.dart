import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as log;

import 'community_story.dart';

class StoriesController extends GetxController {
  RxBool isImgAvailable = false.obs;
  final _picker = ImagePicker();
  RxString selectedImagePath = ''.obs;
  RxString selectedImageSize = ''.obs;
  RxBool isLoading = false.obs;
  RxString uploadStatus = ''.obs;
  final _userDatBaseReference = FirebaseFirestore.instance.collection("story");

  final _storyList = RxList<Story>([]);
  int currentStoryIndex = -1; // Track the current story index

  List<Story> get stories => _storyList;

  @override
  void onInit() {
    super.onInit();
    _storyList.bindStream(getStories() as Stream<List<Story>>);
  }

  Stream<List<Story>> getStories() {
    return FirebaseFirestore.instance
        .collection('story')
        .snapshots()
        .map((snapshot) {
      List<Story> stories = snapshot.docs.map((doc) => Story.fromDocumentSnapshot(doc)).toList();

      // Sort stories: unviewed stories first, then by creation date
      stories.sort((a, b) {
        if (a.isViewed == b.isViewed) {
          // If both are viewed/unviewed, sort by creation date
          DateTime? dateA = a.createdAt?.toDate();
          DateTime? dateB = b.createdAt?.toDate();

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;

          return dateB.compareTo(dateA);
        }
        return a.isViewed ? 1 : -1; // Unviewed stories come first
      });

      return stories;
    });
  }

  Future<void> deleteOldStoriesFromFirestore() async {
    final now = DateTime.now();
    final querySnapshot = await FirebaseFirestore.instance.collection('story').get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data.containsKey('createdAt') ? data['createdAt'] as Timestamp? : null;

      if (createdAt != null) {
        final createdAtDate = createdAt.toDate();
        if (now.difference(createdAtDate).inDays > 2) {
          await doc.reference.delete();
        }
      }
    }
  }

  Future<bool> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;
      selectedImageSize.value = "${((File(selectedImagePath.value)).lengthSync() / 1024 / 1024).toStringAsFixed(2)} Mb";
      isImgAvailable.value = true;
      return true;
    } else {
      isImgAvailable.value = false;
      return false;
    }
  }

  void createStory({
    required String userName,
    required String userUrl,
  }) {
    isLoading.value = true;
    uploadImage().then((url) {
      if (url != null) {
        saveDataToDb(
          url: url,
          userName: userName,
          userUrl: userUrl,
        ).then((value) {
          isLoading.value = false;
          uploadStatus.value = 'Story uploaded successfully!';
          _startStatusClearTimer();
        });
      } else {
        isLoading.value = false;
        uploadStatus.value = 'Failed to upload story.';
        _startStatusClearTimer();
      }
    });
  }

  Future<String?> uploadImage() async {
    File file = File(selectedImagePath.value);
    FirebaseStorage storage = FirebaseStorage.instance;

    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    String randomStr = String.fromCharCodes(Iterable.generate(
      8,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));

    try {
      await storage.ref('uploads/story/$randomStr').putFile(file);
    } on FirebaseException catch (e) {
      log.log(e.code.toString());
    }

    String downloadURL = await storage.ref('uploads/story/$randomStr').getDownloadURL();

    return downloadURL;
  }

  Future<void> saveDataToDb({
    required String url,
    required String userName,
    required String userUrl,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final createdAt = FieldValue.serverTimestamp();

    _userDatBaseReference.doc(user.uid).get().then((value) async {
      if (value.exists) {
        await _userDatBaseReference.doc(user.uid).update({
          'storyUrl': FieldValue.arrayUnion([url]),
        });
      } else {
        await _userDatBaseReference.doc(user.uid).set({
          'userUid': user.uid,
          'userName': userName,
          'userUrl': userUrl,
          'storyUrl': FieldValue.arrayUnion([url]),
          'viewers': {},
          'createdAt': createdAt,
        });
      }
    });
  }

  Future<void> deleteStory(String storyUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = _userDatBaseReference.doc(user.uid);
    final userSnapshot = await userDoc.get();
    final userData = userSnapshot.data() as Map<String, dynamic>;

    List<String> storyUrls = List<String>.from(userData['storyUrl'] ?? []);
    storyUrls.remove(storyUrl);

    if (storyUrls.isEmpty) {
      await userDoc.delete();
    } else {
      await userDoc.update({'storyUrl': storyUrls});
    }
  }

  Future<void> markStoryAsViewed(String userUid, String storyUrl, String currentUserUid) async {
    try {
      final storyRef = FirebaseFirestore.instance.collection('story').doc(userUid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final storyDoc = await transaction.get(storyRef);

        if (storyDoc.exists) {
          final viewers = storyDoc.get('viewers') as Map<String, dynamic>? ?? {};
          final storyViewers = viewers[storyUrl] as Map<String, dynamic>? ?? {};

          if (!storyViewers.containsKey(currentUserUid)) {
            storyViewers[currentUserUid] = true;
            viewers[storyUrl] = storyViewers;

            // Mark the story as viewed
            Story story = stories.firstWhere((s) => s.storyUrl == storyUrl);
            story.markAsViewed(); // Update the isViewed property

            transaction.update(storyRef, {
              'viewers': viewers,
              'isViewed': true, // Update the Firestore document
            });

            // Move the viewed story to the end of the list
            stories.remove(story);
            stories.add(story);
          }
        }
      });
    } catch (e) {
      print('Failed to mark story as viewed: $e');
    }
  }

  Future<Story?> getNextStory() async {
    if (_storyList.isEmpty) {
      return null;
    }

    currentStoryIndex++;

    if (currentStoryIndex >= _storyList.length) {
      currentStoryIndex = 0;
    }

    return _storyList[currentStoryIndex];
  }

  void _startStatusClearTimer() {
    Timer(Duration(seconds: 3), () {
      uploadStatus.value = '';
    });
  }

  void removeOldStories() {
    final now = DateTime.now();
    stories.removeWhere((story) {
      final storyCreationTime = (story.createdAt as Timestamp?)?.toDate();
      if (storyCreationTime == null) {
        return false;
      }
      return now.difference(storyCreationTime).inDays > 2;
    });
  }
}
