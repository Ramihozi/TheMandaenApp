import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final List<String> storyUrl;
  final String userName;
  final String userUrl;
  final String userUid;
  final Map<String, Map<String, bool>> viewers;
  final String storyId;
  final Timestamp? createdAt; // Make createdAt nullable
  bool isViewed; // Add property to track if the story has been viewed

  Story({
    required this.storyUrl,
    required this.userName,
    required this.userUrl,
    required this.userUid,
    required this.viewers,
    required this.storyId,
    this.createdAt, // Initialize createdAt as optional
    this.isViewed = false, // Default to false
  });

  // Factory to create a Story from a document snapshot
  factory Story.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Story(
      storyUrl: List<String>.from(data['storyUrl'] ?? []),
      userName: data['userName'] ?? '',
      userUrl: data['userUrl'] ?? '',
      userUid: data['userUid'] ?? '',
      viewers: _parseViewers(data['viewers']),
      storyId: doc.id,
      createdAt: data['createdAt'] != null ? data['createdAt'] as Timestamp : null, // Safely cast createdAt
      isViewed: data['isViewed'] ?? false, // Fetch the viewed status from Firestore
    );
  }

  // Parse the viewers field from the Firestore data
  static Map<String, Map<String, bool>> _parseViewers(dynamic viewersData) {
    final Map<String, dynamic> viewersMap = viewersData as Map<String, dynamic>? ?? {};
    final Map<String, Map<String, bool>> parsedViewers = {};

    viewersMap.forEach((storyUrl, viewers) {
      final storyViewersMap = viewers as Map<String, dynamic>? ?? {};
      parsedViewers[storyUrl] = storyViewersMap.map(
            (userId, hasViewed) => MapEntry(userId, hasViewed is bool ? hasViewed : false),
      );
    });

    return parsedViewers;
  }

  // Getter to check if the current user has viewed the story
  bool hasViewed(String currentUserUid) {
    // Check if the currentUserUid exists in the viewers map for any storyUrl
    for (final story in storyUrl) {
      if (viewers.containsKey(story) && viewers[story]!.containsKey(currentUserUid)) {
        return viewers[story]![currentUserUid] == true;
      }
    }
    return false;
  }

  // Method to mark the story as viewed
  void markAsViewed() {
    isViewed = true;
  }
}
