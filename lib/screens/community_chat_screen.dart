import 'package:flutter/material.dart';
import 'community_friends_tab.dart'; // Import your FriendsTab widget

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({Key? key}) : super(key: key);

  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

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
          // First tab view (Placeholder for Chat content)
          const Center(
            child: Text('Chat Tab Content'),
          ),
          // Second tab view (FriendsTab)
          FriendsTab(),
        ],
      ),
    );
  }
}
