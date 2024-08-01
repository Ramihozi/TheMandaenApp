import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewerListScreen extends StatelessWidget {
  final String storyUrl;

  ViewerListScreen({required this.storyUrl});

  Future<List<Map<String, dynamic>>> _fetchViewersDetails() async {
    List<Map<String, dynamic>> viewersDetails = [];
    final firestore = FirebaseFirestore.instance;

    try {
      // Fetch the story document based on the storyUrl
      final storyDoc = await firestore.collection('story').where('storyUrl', arrayContains: storyUrl).limit(1).get();

      if (storyDoc.docs.isEmpty) {
        throw Exception('Story not found');
      }

      final storyData = storyDoc.docs.first.data();
      final viewersMap = Map<String, dynamic>.from(storyData['viewers'][storyUrl] ?? {});

      // Process each viewer
      for (String uid in viewersMap.keys) {
        try {
          final userDoc = await firestore.collection('user').doc(uid).get();
          if (userDoc.exists) {
            final data = userDoc.data() ?? {};
            viewersDetails.add({
              'name': data['name'] ?? 'Unknown',
              'profilePictureUrl': data['url'] ?? '',
            });
          }
        } catch (e) {
          print('Failed to fetch viewer data for UID $uid: $e');
        }
      }
    } catch (e) {
      print('Failed to fetch story document: $e');
    }

    return viewersDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchViewersDetails(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Viewers', style: TextStyle(color: Colors.yellow));
            }
            final viewersCount = snapshot.data!.length;
            return Text(
              'Viewers ($viewersCount)',
              style: TextStyle(color: Colors.yellow),
            );
          },
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchViewersDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No viewers', style: TextStyle(color: Colors.grey)));
          }
          final viewersDetails = snapshot.data!;
          return ListView(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            children: viewersDetails.map((viewer) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  leading: CircleAvatar(
                    radius: 24, // Smaller profile picture
                    backgroundImage: viewer['profilePictureUrl'] != ''
                        ? NetworkImage(viewer['profilePictureUrl'])
                        : null,
                    child: viewer['profilePictureUrl'] == ''
                        ? Icon(Icons.person, size: 24, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    viewer['name'],
                    style: TextStyle(
                      fontSize: 14, // Smaller text size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  tileColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }
}
