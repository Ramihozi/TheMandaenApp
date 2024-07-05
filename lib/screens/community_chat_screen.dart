import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          'Chat',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}