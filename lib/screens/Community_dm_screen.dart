import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Community_dm_message.dart'; // Adjust import based on your actual message model location
import 'community_chat_service.dart'; // Import ChatService

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

  // Cache user data to prevent frequent reads
  final Map<String, String?> _userImages = {};

  @override
  void initState() {
    super.initState();
    // Fetch the friend's profile picture at the start
    _fetchFriendProfileImage();
  }

  void _fetchFriendProfileImage() {
    FirebaseFirestore.instance.collection('user').doc(widget.friendId).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _userImages[widget.friendId] = snapshot.get('url') as String?;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _userImages[widget.friendId] != null
                  ? NetworkImage(_userImages[widget.friendId]!)
                  : null, // No fallback image
              radius: 20,
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.friendName,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

                List<Message> messages = [];
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    messages.add(Message.fromMap(doc.data() as Map<String, dynamic>));
                  }
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Message message = messages[index];
                    bool isMe = message.senderId == _auth.currentUser!.uid;
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

  Widget _buildMessage(Message message, bool isMe) {
    // Cache the image URL if not already cached
    if (!_userImages.containsKey(message.senderId)) {
      FirebaseFirestore.instance.collection('user').doc(message.senderId).get().then((snapshot) {
        if (snapshot.exists) {
          _userImages[message.senderId] = snapshot.get('url') as String?;
          setState(() {}); // Trigger a rebuild to update the UI
        }
      });
    }

    String? imageUrl = _userImages[message.senderId];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl) as ImageProvider<Object>?
                  : null, // No fallback image
            ),
          const SizedBox(width: 8.0),
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
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type a message...',
              ),
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

  void _sendMessage(String text) async {
    try {
      await _chatService.sendMessage(widget.friendId, text);
      _controller.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }
}
