import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:the_mandean_app/screens/user.dart';
import 'community_profile_controller.dart';
import 'firebase_service.dart';
import 'community_dm_screen.dart'; // Import the ChatScreen or your desired DM screen
import 'package:get/get.dart'; // Import GetX package

class FriendsTab extends StatefulWidget {
  final VoidCallback onUserBlocked;

  FriendsTab({required this.onUserBlocked});

  @override
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final FirebaseService firebaseService = FirebaseService();
  late String currentUserId = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Initialize ProfileController
  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
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
          title: Text(
            _profileController.isEnglish.value ? 'Confirm Block' : 'تأكيد الحظر',
            style: TextStyle(
              fontSize: _profileController.isEnglish.value ? 18.0 : 22.0, // Adjust font size
            ),
          ),
          content: Text(
            _profileController.isEnglish.value
                ? 'Are you sure you want to block ${user.name}?\nThis will remove all posts and messages associated with the user!'
                : 'هل أنت متأكد أنك تريد حظر ${user.name}؟\nسيؤدي ذلك إلى إزالة جميع المنشورات والرسائل المرتبطة بالمستخدم!',
            style: TextStyle(
              fontSize: _profileController.isEnglish.value ? 14.0 : 18.0, // Adjust font size
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                _profileController.isEnglish.value ? 'Cancel' : 'إلغاء',
                style: TextStyle(
                  fontSize: _profileController.isEnglish.value ? 14.0 : 18.0, // Adjust font size
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                _profileController.isEnglish.value ? 'Block' : 'حظر',
                style: TextStyle(
                  fontSize: _profileController.isEnglish.value ? 14.0 : 18.0, // Adjust font size
                ),
              ),
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.black), // Text color
                  decoration: InputDecoration(
                    hintText: _profileController.isEnglish.value
                        ? 'Search by name'
                        : 'ابحث بالاسم',
                    hintStyle: TextStyle(
                      color: Colors.grey[600], // Hint text color
                      fontSize: _profileController.isEnglish.value ? 14.0 : 16.0, // Adjust font size
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.black), // Icon color
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.black),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.black), // Default outline color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.black, width: 2.0), // Outline color when focused
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.black), // Outline color when enabled
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<User>>(
            stream: firebaseService.getUsersStream(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    _profileController.isEnglish.value
                        ? 'No friends found'
                        : 'لم يتم العثور على أصدقاء',
                    style: TextStyle(
                      fontSize: _profileController.isEnglish.value ? 14.0 : 18.0, // Adjust font size
                    ),
                  ),
                );
              }

              List<User> users = snapshot.data!
                  .where((user) => user.name.toLowerCase().contains(_searchQuery))
                  .toList();

              if (users.isEmpty && _searchQuery.isNotEmpty) {
                return Center(
                  child: Text(
                    _profileController.isEnglish.value
                        ? 'No users found for "$_searchQuery"'
                        : 'لم يتم العثور على مستخدمين لـ "$_searchQuery"',
                    style: TextStyle(
                      fontSize: _profileController.isEnglish.value ? 14.0 : 18.0, // Adjust font size
                    ),
                  ),
                );
              }

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
                        radius: 30, // Increased size by 10 px from default 20
                        backgroundImage: NetworkImage(user.imageUrl),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14.0, // Uniform font size for names
                            ),
                          ),
                          SizedBox(height: 4.0), // Space between name and text
                          Text(
                            _profileController.isEnglish.value
                                ? 'Tap to chat'
                                : 'اضغط للدردشة',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: _profileController.isEnglish.value ? 14.0 : 16.0, // Adjust font size
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _profileController.isEnglish.value
                                ? 'Block user'
                                : 'حظر المستخدم',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: _profileController.isEnglish.value ? 12.0 : 15.0, // Adjust font size
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
          ),
        ),
      ],
    );
  }
}
