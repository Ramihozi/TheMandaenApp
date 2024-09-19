import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Community_dm_message.dart'; // Adjust import based on your actual message model location
import 'community_chat_service.dart'; // Import ChatService
import 'community_view_profile.dart';
import 'firebase_messagin_service.dart';
import 'package:flutter/services.dart'; // For clipboard functionality



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
  final Map<String, String?> _userImages = {};

  @override
  void initState() {
    super.initState();
    _markMessagesAsSeen();
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
                    final isLatest = index == 0; // The latest message is the first item in reversed ListView
                    return _buildMessage(message, isMe, isLatest);
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

  Widget _buildMessage(Message message, bool isMe, bool isLatest) {
    // Load the user image if not already loaded
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

    // Determine message status
    String status = '';
    if (isMe && isLatest) {
      status = message.isRead[widget.friendId] ?? false ? 'Seen' : 'Delivered';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                radius: 18,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl) as ImageProvider<Object>?
                    : null,
                child: imageUrl == null ? const Icon(Icons.person) : null,
              ),
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
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blueAccent : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 18.0, // Increased font size for text
                        fontFamily: 'Arial', // Use a clean font style here
                      ),
                      children: _parseText(message.text),
                    ),
                  ),
                ),
                if (isMe && isLatest)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseText(String text) {
    final emojiPattern = RegExp(
      r'(\p{Emoji}|[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{2300}-\u{23FF}\u{2B50}\u{2934}\u{2935}\u{2B06}\u{2194}-\u{21AA}])',
      unicode: true,
    );
    final spans = <TextSpan>[];
    final matches = emojiPattern.allMatches(text);
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(fontSize: 22.0), // Increased font size for emojis
      ));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
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
