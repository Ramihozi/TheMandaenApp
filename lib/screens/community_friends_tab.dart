import 'package:flutter/material.dart';
import 'package:the_mandean_app/screens/user.dart';
import 'package:the_mandean_app/screens/Community_dm_screen.dart';
import 'firebase_service.dart'; // Import your ChatScreen

class FriendsTab extends StatelessWidget {
  final FirebaseService firebaseService = FirebaseService();

  FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: firebaseService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found.'));
        } else {
          List<User> users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              User user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.imageUrl),
                ),
                title: Text(user.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        friendId: user.id,
                        friendName: user.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
