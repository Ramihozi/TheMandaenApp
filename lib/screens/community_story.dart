import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final List<String> storyUrl;
  final String userName;
  final String userUrl;
  final String userUid;
  final Map<String, Map<String, bool>> viewers;
  final String storyId;
  final Timestamp? createdAt; // Make createdAt nullable

  Story({
    required this.storyUrl,
    required this.userName,
    required this.userUrl,
    required this.userUid,
    required this.viewers,
    required this.storyId,
    this.createdAt, // Initialize createdAt as optional
  });

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
    );
  }

  static Map<String, Map<String, bool>> _parseViewers(dynamic viewersData) {
    final Map<String, dynamic> viewersMap = viewersData as Map<String, dynamic>? ?? {};
    final Map<String, Map<String, bool>> parsedViewers = {};

    viewersMap.forEach((storyUrl, viewers) {
      final storyViewersMap = viewers as Map<String, dynamic>? ?? {};
      parsedViewers[storyUrl] = storyViewersMap.map(
              (userId, hasViewed) => MapEntry(userId, hasViewed is bool ? hasViewed : false)
      );
    });

    return parsedViewers;
  }
}
