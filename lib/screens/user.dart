import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id; // Add this field
  final String name;
  final String imageUrl;

  User({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Factory method to convert DocumentSnapshot to User object
  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return User(
      id: snapshot.id,
      name: data['name'] ?? '',
      imageUrl: data['url'] ?? '',
    );
  }
}
