import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final List<String> storyUrl;
  final String userName;
  final String userUrl;
  final String userUid;
  final Map<String, Map<String, bool>> viewers; // Updated to handle nested map

  Story({
    required this.storyUrl,
    required this.userName,
    required this.userUrl,
    required this.userUid,
    required this.viewers,
  });

  factory Story.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // Check if data is null
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Story(
      storyUrl: List<String>.from(data['storyUrl'] ?? []),
      userName: data['userName'] ?? '',
      userUrl: data['userUrl'] ?? '',
      userUid: data['userUid'] ?? '',
      viewers: _parseViewers(data['viewers']),
    );
  }

  // Helper method to handle the parsing of viewers
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
