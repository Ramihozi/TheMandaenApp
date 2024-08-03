import 'dart:async'; // Import for Timer
import 'dart:convert'; // For JSON encoding/decoding
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

  List<Story> get stories => _storyList;

  @override
  void onInit() {
    super.onInit();
    _storyList.bindStream(getStories() as Stream<List<Story>>);
  }

  Stream<List<Story>> getStories() {
    return FirebaseFirestore.instance.collection('story').snapshots().map((
        snapshot) {
      return snapshot.docs.map((doc) => Story.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  Future<bool> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;
      selectedImageSize.value =
      "${((File(selectedImagePath.value)).lengthSync() / 1024 / 1024)
          .toStringAsFixed(2)} Mb";

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

    String downloadURL = await storage.ref('uploads/story/$randomStr')
        .getDownloadURL();

    return downloadURL;
  }

  Future<void> saveDataToDb({
    required String url,
    required String userName,
    required String userUrl,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

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
          'viewers': {}, // Initialize viewers as an empty map
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
    storyUrls.remove(storyUrl); // Remove the specific story URL

    if (storyUrls.isEmpty) {
      await userDoc.delete(); // Delete the user document if no stories are left
    } else {
      await userDoc.update({'storyUrl': storyUrls});
    }
  }

  Future<void> markStoryAsViewed(String userUid, String storyUrl,
      String currentUserUid) async {
    try {
      final storyRef = FirebaseFirestore.instance.collection('story').doc(
          userUid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final storyDoc = await transaction.get(storyRef);

        if (storyDoc.exists) {
          final viewers = storyDoc.get('viewers') as Map<String, dynamic>? ??
              {};

          final storyViewers = viewers[storyUrl] as Map<String, dynamic>? ?? {};

          final storyViewersMap = Map<String, bool>.from(
              storyViewers.map((key, value) =>
                  MapEntry(key, value is bool ? value : false))
          );

          if (!storyViewersMap.containsKey(currentUserUid)) {
            storyViewersMap[currentUserUid] =
            true; // Mark the current user's UID as viewed
            viewers[storyUrl] = storyViewersMap;
            transaction.update(storyRef, {'viewers': viewers});
          }
        }
      });
    } catch (e) {
      print('Failed to mark story as viewed: $e');
    }
  }

  void _startStatusClearTimer() {
    Timer(Duration(seconds: 3), () {
      uploadStatus.value = ''; // Clear the status message after 3 seconds
    });
  }
}
