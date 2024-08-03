import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_chat_service.dart';
import 'community_stories_controller.dart';
import 'community_story.dart';
import 'viewer_list_screen.dart';

class StoryViewFullScreen extends StatefulWidget {
  const StoryViewFullScreen({super.key});

  @override
  State<StoryViewFullScreen> createState() => _StoryViewFullScreenState();
}

class _StoryViewFullScreenState extends State<StoryViewFullScreen> {
  late final Story story;
  final StoryController controller = StoryController();
  final List<StoryItem> storyItems = [];
  bool _isAppBarVisible = true;
  bool _isPaused = false;
  bool _isXButtonVisible = true;
  int _currentIndex = 0;
  bool _isDeleting = false;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    story = Get.arguments[0];
    retrieveStories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markStoryAsViewed();
    });
  }

  void retrieveStories() {
    if (story.storyUrl.isNotEmpty) {
      for (var element in story.storyUrl) {
        storyItems.add(
          StoryItem.pageImage(
            url: element,
            controller: controller,
            caption: null,
          ),
        );
      }
    }
  }

  void _markStoryAsViewed() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && story.userUid.isNotEmpty) {
      try {
        final storiesController = Get.find<StoriesController>();
        if (_currentIndex >= 0 && _currentIndex < story.storyUrl.length) {
          final currentStoryUrl = story.storyUrl[_currentIndex];
          await storiesController.markStoryAsViewed(
              story.userUid, currentStoryUrl, currentUser.uid);
        }
      } catch (e) {
        print('Failed to mark story as viewed: $e');
      }
    }
  }

  Future<void> _sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && _messageController.text.trim().isNotEmpty) {
      try {
        await _chatService.sendMessage(story.userUid, _messageController.text.trim());
        _messageController.clear();

        // Use a slight delay before showing the snackbar
        Future.delayed(Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Message sent successfully');
        });

        // Resume the story if it was paused
        if (_isPaused) {
          controller.play();
          setState(() {
            _isPaused = false;
            _isTextFieldFocused = false;
          });
        }

        // Ensure clean navigation or exit
        Get.back();  // This should exit the page cleanly
      } catch (e) {
        Get.snackbar('Error', 'Failed to send message: $e');
      }
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    controller.pause();
    setState(() {
      _isPaused = true;
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    controller.play();
    setState(() {
      _isPaused = false;
    });
  }

  void _viewViewerList() async {
    if (story.storyUrl.isNotEmpty) {
      final currentStoryUrl = story.storyUrl[_currentIndex];
      controller.pause();
      await Get.to(() => ViewerListScreen(storyUrl: currentStoryUrl));
      controller.play();
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Story"),
          content: Text("Are you sure you want to delete this story?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                // Logic to delete the story
              },
            ),
          ],
        );
      },
    );
  }

  void _exitStoryView() {
    Get.back();
  }

  void _handleTextFieldSubmit(String value) {
    _sendMessage();
    FocusScope.of(context).unfocus(); // Hide the keyboard
    setState(() {
      _isTextFieldFocused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (_isPaused) {
            controller.play();
            setState(() {
              _isPaused = false;
              _isTextFieldFocused = false;
            });
          }
        },
        child: Stack(
          children: [
            StoryView(
              storyItems: storyItems,
              onComplete: () {
                if (!_isDeleting) {
                  Get.back();
                }
              },
              progressPosition: ProgressPosition.top,
              repeat: false,
              controller: controller,
              onStoryShow: (storyItem, index) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _currentIndex = index;
                    });
                    _markStoryAsViewed();
                  }
                });
              },
            ),
            if (_isAppBarVisible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.black.withOpacity(0),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        if (story.userUrl.isNotEmpty)
                          CircleAvatar(
                            backgroundImage: NetworkImage(story.userUrl),
                            radius: 16,
                          ),
                        if (story.userUrl.isNotEmpty)
                          SizedBox(width: 8),
                        if (story.userName.isNotEmpty)
                          Flexible(
                            child: Text(
                              story.userName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Spacer(),
                        if (currentUser != null &&
                            currentUser.uid == story.userUid)
                          Transform.translate(
                            offset: Offset(-10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                      Icons.visibility, color: Colors.white),
                                  onPressed: _viewViewerList,
                                  tooltip: 'Viewers',
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    if (!_isDeleting) {
                                      _showDeleteConfirmationDialog();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_isXButtonVisible)
              Positioned(
                top: 73,
                right: 5,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: _exitStoryView,
                  tooltip: 'Close',
                ),
              ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  if (_isTextFieldFocused) {
                    controller.pause();
                    setState(() {
                      _isPaused = true;
                    });
                  }
                },
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      controller.pause();
                      setState(() {
                        _isPaused = true;
                        _isTextFieldFocused = true;
                      });
                    } else {
                      controller.play();
                      setState(() {
                        _isPaused = false;
                        _isTextFieldFocused = false;
                      });
                    }
                  },
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: _isTextFieldFocused ? Colors.blue : Colors.white,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onSubmitted: _handleTextFieldSubmit,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 16,
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    _handleTextFieldSubmit(_messageController.text.trim());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
