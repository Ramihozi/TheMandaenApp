import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Community_dm_message.dart'; // Adjust import based on your actual message model location

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;

  const ChatScreen({super.key, required this.friendId, required this.friendName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();

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
              stream: _firestore
                  .collection('messages')
                  .doc(_getChatRoomId())
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
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
                      future: _firestore.collection('user').doc(message.senderId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
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
          Expanded(
            child: Container(
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
                sendMessage(_controller.text);
              }
            },
          ),
        ],
      ),
    );
  }

  void sendMessage(String text) async {
    try {
      String userId = _auth.currentUser!.uid;

      // Fetch sender's name from Firestore based on userId
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .get();

      String userName = userDoc.exists ? userDoc.get('name') ?? 'Unknown' : 'Unknown';

      Message message = Message(
        senderId: userId,
        senderName: userName,
        text: text,
        timestamp: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('messages')
          .doc(_getChatRoomId())
          .collection('chats')
          .add(message.toMap());

      _controller.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  String _getChatRoomId() {
    List<String> ids = [_auth.currentUser!.uid, widget.friendId];
    ids.sort();
    return ids.join('_');
  }
}
