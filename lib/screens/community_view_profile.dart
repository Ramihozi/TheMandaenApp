import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewProfileScreen extends StatelessWidget {
  final String userId;

  // Constructor with a required userId parameter
  ViewProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userRef = FirebaseFirestore.instance.collection('user').doc(userId);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'User Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['name'] ?? 'No Name';
          final url = userData['url'] ?? '';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 160,
                    backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
                    child: url.isEmpty ? Icon(Icons.person, size: 60) : null,
                  ),
                  SizedBox(height: 80), // Adjusted spacing
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Add more profile details here
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
