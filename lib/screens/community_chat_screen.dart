import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'Community_dm_screen.dart';
import 'community_friends_tab.dart';
import 'community_chat_service.dart';

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({super.key});

  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCurrentUserName();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUserName() async {
    try {
      DocumentSnapshot userSnapshot = await _firestore
          .collection('user')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          var userData = userSnapshot.data() as Map<String, dynamic>;
          _currentUserName = userData['name'] ?? 'User';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user name: $e');
      }
    }
  }

  void switchToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                _currentUserName,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.amber,
              tabs: const [
                Tab(text: 'Chat'),
                Tab(text: 'All Users'),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Set elevation to 0 for a flat, solid color AppBar
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatTab(chatService: _chatService),
          FriendsTab(onUserBlocked: () => switchToTab(0)),
        ],
      ),
    );
  }
}

class ChatTab extends StatelessWidget {
  final ChatService chatService;

  ChatTab({super.key, required this.chatService});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('user').doc(_auth.currentUser!.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
        List<String> blockedUsers = List<String>.from(userData['blockedUsers'] ?? []);

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('messages')
              .where('participants', arrayContains: _auth.currentUser!.uid)
              .snapshots(),
          builder: (context, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (chatSnapshot.hasError) {
              if (kDebugMode) {
                print('Error fetching chats: ${chatSnapshot.error}');
              }
              return const Center(child: Text('Error fetching chats.'));
            }

            if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No chats available.'));
            }

            List<DocumentSnapshot> chatRooms = chatSnapshot.data!.docs;
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                DocumentSnapshot chatRoom = chatRooms[index];
                String friendId = _getFriendId(chatRoom);

                if (blockedUsers.contains(friendId)) {
                  _deleteChat(chatRoom.id);
                  return SizedBox.shrink();
                }

                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('user').doc(friendId).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const ListTile(title: Text('Loading...'));
                    }

                    if (userSnapshot.hasError) {
                      if (kDebugMode) {
                        print('Error fetching user data: ${userSnapshot.error}');
                      }
                      return const ListTile(title: Text('Error loading user data.'));
                    }

                    var friendData = userSnapshot.data!.data() as Map<String, dynamic>;
                    String friendName = friendData['name'] ?? 'Unknown';
                    String friendPhotoUrl = friendData['url'] ?? 'assets/images/account.png';
                    String latestMessage = chatRoom['latestMessage'] ?? '';
                    Timestamp timestamp = chatRoom['updatedAt'] ?? Timestamp.now();
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate = timeago.format(dateTime);

                    bool isRead = chatRoom['isRead']?[_auth.currentUser!.uid] ?? false;

                    return Card(
                      elevation: 4.0,
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
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
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                latestMessage,
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                          // Mark messages as read when navigating to the chat screen
                          _firestore
                              .collection('messages')
                              .doc(chatRoom.id)
                              .update({
                            'isRead.${_auth.currentUser!.uid}': true,
                          });

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

  Future<void> _deleteChat(String chatId) async {
    DocumentReference chatDoc = _firestore.collection('messages').doc(chatId);
    CollectionReference messagesCollection = chatDoc.collection('chats');
    QuerySnapshot messagesSnapshot = await messagesCollection.get();
    WriteBatch batch = _firestore.batch();

    for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
      batch.delete(messageDoc.reference);
    }

    batch.delete(chatDoc);
    await batch.commit();
  }
}
