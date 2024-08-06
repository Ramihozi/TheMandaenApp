import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Community_dm_message.dart'; // Adjust import based on your actual message model location
import 'community_chat_service.dart'; // Import ChatService
import 'community_view_profile.dart';
import 'firebase_messagin_service.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;

  const ChatScreen({super.key, required this.friendId, required this.friendName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService(); // Instantiate ChatService
  final FirebaseMessagingService _firebaseMessagingService = FirebaseMessagingService(); // Initialize the service

  final Map<String, String?> _userImages = {};

  @override
  void initState() {
    super.initState();
    _markMessagesAsSeen();
    _firebaseMessagingService.init(); // Initialize Firebase Messaging
  }

  Future<void> _markMessagesAsSeen() async {
    try {
      await _chatService.markMessagesAsSeen(widget.friendId);
    } catch (e) {
      if (kDebugMode) {
        print('Error marking messages as seen: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Solid white background
        elevation: 0, // Remove shadow
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewProfileScreen(userId: widget.friendId),
              ),
            );
          },
          child: Row(
            children: [
              FutureBuilder<String?>(
                future: _getUserProfileImage(widget.friendId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: const CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: snapshot.data != null
                          ? NetworkImage(snapshot.data!)
                          : null, // Use null if no image URL is available
                    );
                  }
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey, // Default to a grey background
                    child: const Icon(Icons.person), // Placeholder icon
                  );
                },
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.friendName,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getChatMessagesStream(widget.friendId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No messages'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return Message.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                _markMessagesAsSeen();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _auth.currentUser!.uid;
                    return _buildMessage(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Future<String?> _getUserProfileImage(String userId) async {
    if (!_userImages.containsKey(userId)) {
      final snapshot = await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (snapshot.exists) {
        _userImages[userId] = snapshot.get('url') as String?;
      }
    }
    return _userImages[userId];
  }

  Widget _buildMessage(Message message, bool isMe) {
    if (!_userImages.containsKey(message.senderId)) {
      FirebaseFirestore.instance.collection('user').doc(message.senderId)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          _userImages[message.senderId] = snapshot.get('url') as String?;
          setState(() {});
        }
      });
    }

    String? imageUrl = _userImages[message.senderId];

    String status = '';
    if (isMe) {
      status = message.isRead[widget.friendId] ?? false ? 'Seen' : 'Delivered';
    } else {
      status = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewProfileScreen(userId: message.senderId),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl) as ImageProvider<Object>?
                      : null, // Use null if no image URL is available
                  child: imageUrl == null ? const Icon(Icons.person) : null, // Placeholder icon
                )
            ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.storyUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4.0),
                    child: Image.network(
                      message.storyUrl!,
                      height: 200.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                if (isMe)
                  Text(
                    status,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type a message...',
              ),
              minLines: 1,
              maxLines: null, // Expands the text field vertically as the user types more
              keyboardType: TextInputType.multiline,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _sendMessage(_controller.text);
              }
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text, {String? storyUrl}) async {
    try {
      final message = {
        'message': text,
        'storyUrl': storyUrl,
      };

      await _chatService.sendMessage(widget.friendId, message);
      _controller.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }
}
