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

  void switchToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          title: const Text(''),
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
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatTab(chatService: _chatService),
          FriendsTab(onUserBlocked: () => switchToTab(0)), // Passing the callback
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
        List<dynamic> dynamicBlockedUsers = userData['blockedUsers'] ?? [];
        List<String> blockedUsers = List<String>.from(dynamicBlockedUsers);

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
              if (kDebugMode) {
                print('Error fetching chats: ${snapshot.error}');
              }
              return const Center(child: Text('Error fetching chats.'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              if (kDebugMode) {
                print('No chats available. Snapshot data: ${snapshot.data}');
              }
              return const Center(child: Text('No chats available'));
            }

            List<DocumentSnapshot> chatRooms = snapshot.data!.docs;
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

                    bool isRead = chatRoom['isRead']?[_auth.currentUser!.uid] ?? true;

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
                            color: Colors.teal,
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
