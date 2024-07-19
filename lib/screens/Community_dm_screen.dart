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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
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
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('user').doc(message.senderId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(); // Return an empty widget while waiting
                        }
                        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                          return _buildMessage(message, isMe, null);
                        }
                        String? imageUrl = snapshot.data!.get('url') as String?;
                        return _buildMessage(message, isMe, imageUrl);
                      },
                    );
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

  Widget _buildMessage(Message message, bool isMe, String? imageUrl) {
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
                  : const AssetImage('assets/images/account.png') as ImageProvider<Object>?,
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
