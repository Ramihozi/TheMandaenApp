import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> blockedUsers; // Add this field

  User({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.blockedUsers, // Initialize this field
  });

  // Factory method to convert DocumentSnapshot to User object
  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return User(
      id: snapshot.id,
      name: data['name'] ?? '',
      imageUrl: data['url'] ?? '',
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []), // Handle the blockedUsers field
    );
  }

  // Convert User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': imageUrl,
      'blockedUsers': blockedUsers,
    };
  }
}
