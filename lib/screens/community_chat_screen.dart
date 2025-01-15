import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'Community_dm_screen.dart';
import 'community_friends_tab.dart';
import 'community_chat_service.dart';
import 'profile_tab/community_profile_controller.dart';

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

  // Initialize ProfileController
  final ProfileController _profileController = Get.find<ProfileController>();

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
                _currentUserName, // Keep the name in the current language
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
              tabs: [
                Tab(
                  child: Text(
                    _profileController.isEnglish.value ? 'Chat' : 'الدردشة',
                    style: TextStyle(
                      fontSize: _profileController.isEnglish.value ? 16.0 : 19.0, // Adjust font size
                      color: Colors.black, // Matching label color
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    _profileController.isEnglish.value ? 'All Users' : 'جميع المستخدمين',
                    style: TextStyle(
                      fontSize: _profileController.isEnglish.value ? 16.0 : 19.0, // Adjust font size
                      color: Colors.black, // Matching label color
                    ),
                  ),
                ),
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

class ChatTab extends StatefulWidget {
  final ChatService chatService;

  ChatTab({super.key, required this.chatService});

  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _chatRooms = [];
  bool _hasMore = true;
  bool _isLoading = false;
  final int _limit = 20;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _fetchChats();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _hasMore) {
          _fetchChats();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _fetchChats() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save the current scroll position
      final currentScrollPosition = _scrollController.hasClients
          ? _scrollController.position.pixels
          : 0.0;

      Query query = _firestore
          .collection('messages')
          .where('participants', arrayContains: _auth.currentUser!.uid)
          .orderBy('updatedAt', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _chatRooms.addAll(querySnapshot.docs);
          _lastDocument = querySnapshot.docs.last;
          if (querySnapshot.docs.length < _limit) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }

      // Restore the scroll position after loading more chats
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(currentScrollPosition);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chats: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _firestore
          .collection('messages')
          .where('participants', arrayContains: _auth.currentUser!.uid)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs),
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

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No chats available.'));
        }

        _chatRooms = snapshot.data!;

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(8.0),
          itemCount: _chatRooms.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _chatRooms.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            DocumentSnapshot chatRoom = _chatRooms[index];
            String friendId = _getFriendId(chatRoom);

            List<String> blockedUsers = []; // Replace with actual blockedUsers retrieval

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

                if (userSnapshot.hasError || !userSnapshot.data!.exists) {
                  // If there's an error or the user no longer exists, delete the chat
                  _deleteChat(chatRoom.id);
                  return const SizedBox.shrink();
                }

                var friendData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                String friendName = friendData['name'] ?? 'Unknown';
                String friendPhotoUrl = friendData['url'];
                String latestMessage = chatRoom['latestMessage'] ?? '';
                Timestamp timestamp = chatRoom['updatedAt'] ?? Timestamp.now();
                DateTime dateTime = timestamp.toDate();
                String formattedDate = timeago.format(dateTime);

                bool isRead = chatRoom['isRead']?[_auth.currentUser!.uid] ?? false;

                return Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage: friendPhotoUrl.startsWith('http')
                              ? NetworkImage(friendPhotoUrl)
                              : AssetImage(friendPhotoUrl) as ImageProvider,
                        ),
                        if (!isRead)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
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
                        fontSize: 18.0,
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
                              fontSize: 16.0,
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isRead ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
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
