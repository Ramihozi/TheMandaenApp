import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'Community_dm_screen.dart';
import 'community_friends_tab.dart'; // Import your FriendsTab widget
import 'community_chat_service.dart'; // Import ChatService

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({Key? key}) : super(key: key);

  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final ChatService _chatService = ChatService(); // Instantiate ChatService

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          title: const Text(''), // Empty Text widget
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              tabs: const [
                Tab(text: 'Chat'), // First tab
                Tab(text: 'Friends'), // Second tab
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // First tab view displaying all chats
          ChatTab(chatService: _chatService),
          // Second tab view (FriendsTab)
          FriendsTab(),
        ],
      ),
    );
  }
}

class ChatTab extends StatelessWidget {
  final ChatService chatService; // Receive ChatService instance

  ChatTab({required this.chatService});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .where('participants', arrayContains: _auth.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error fetching chats: ${snapshot.error}');
          return const Center(child: Text('Error fetching chats.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No chats available. Snapshot data: ${snapshot.data}');
          return const Center(child: Text('No chats available'));
        }

        List<DocumentSnapshot> chatRooms = snapshot.data!.docs;
        chatRooms.forEach((chatRoom) {
          print('Chat room data: ${chatRoom.data()}');
        });

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            DocumentSnapshot chatRoom = chatRooms[index];
            String friendId = _getFriendId(chatRoom);
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('user').doc(friendId).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const ListTile(title: Text('Loading...'));
                }

                if (snapshot.hasError) {
                  print('Error fetching user data: ${snapshot.error}');
                  return const ListTile(title: Text('Error loading user data.'));
                }

                var friendData = snapshot.data!.data() as Map<String, dynamic>;
                String friendName = friendData['name'] ?? 'Unknown';
                String friendPhotoUrl = friendData['url'] ?? 'assets/images/account.png';
                String latestMessage = chatRoom['latestMessage'] ?? '';
                Timestamp timestamp = chatRoom['updatedAt'] ?? Timestamp.now();
                DateTime dateTime = timestamp.toDate();
                String formattedDate = timeago.format(dateTime);

                // Check if the message is read by the current user
                bool isRead = chatRoom['isRead'][_auth.currentUser!.uid] ?? true;

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: friendPhotoUrl.startsWith('http')
                            ? NetworkImage(friendPhotoUrl)
                            : AssetImage(friendPhotoUrl) as ImageProvider,
                      ),
                      if (!isRead)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    friendName,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestMessage,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Mark the message as read when the chat is opened
                    _firestore
                        .collection('messages')
                        .doc(chatRoom.id)
                        .update({'isRead.${_auth.currentUser!.uid}': true});

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          friendId: friendId,
                          friendName: friendName,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  String _getFriendId(DocumentSnapshot chatRoom) {
    List<dynamic> participants = chatRoom['participants'] ?? [];
    participants.remove(_auth.currentUser!.uid);
    return participants.isNotEmpty ? participants.first : '';
  }
}
