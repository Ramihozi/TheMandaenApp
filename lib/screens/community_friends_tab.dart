import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:the_mandean_app/screens/user.dart';
import 'firebase_service.dart';
import 'community_dm_screen.dart'; // Import the ChatScreen or your desired DM screen

class FriendsTab extends StatefulWidget {
  final VoidCallback onUserBlocked;

  FriendsTab({required this.onUserBlocked});

  @override
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final FirebaseService firebaseService = FirebaseService();
  late String currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    auth.User? user = auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    } else {
      print('No user is logged in');
    }
  }

  Future<void> _confirmBlockUser(User user) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Block'),
          content: Text('Are you sure you want to block ${user.name}?\nThis Will Remove All Posts And Messages Associated With User! '),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Block'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await firebaseService.blockUser(user.id, currentUserId);
      widget.onUserBlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<User>>(
      stream: firebaseService.getUsersStream(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No friends found'));
        }

        List<User> users = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: users.length,
          itemBuilder: (context, index) {
            User user = users[index];
            return Card(
              elevation: 4.0,
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.imageUrl),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 4.0), // Space between name and text
                    Text(
                      'Tap to chat',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Block user',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.0,
                      ),
                    ),
                    SizedBox(width: 4.0), // Space between text and icon
                    IconButton(
                      icon: Icon(Icons.block, color: Colors.amber),
                      onPressed: () {
                        _confirmBlockUser(user);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to the chat screen with the selected friend
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
              ),
            );
          },
        );
      },
    );
  }
}
