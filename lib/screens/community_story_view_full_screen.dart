import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_chat_service.dart';
import 'community_stories_controller.dart';
import 'community_story.dart';
import 'community_view_profile.dart';
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
  List<Story> allStories = []; // Store all stories in chronological order
  bool _isAppBarVisible = true;
  bool _isPaused = false;
  bool _isXButtonVisible = true;
  int _currentIndex = 0;
  bool _isDeleting = false;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isTextFieldFocused = false;
  bool _showMessageSent = false;
  Timer? _sendMessageTimer;

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
    if (currentUser != null && _messageController.text
        .trim()
        .isNotEmpty) {
      try {
        controller.pause();
        setState(() {
          _isPaused = true;
        });

        // Check if it's a story reply
        String? storyUrl;
        if (story.storyUrl.isNotEmpty && _currentIndex >= 0 &&
            _currentIndex < story.storyUrl.length) {
          storyUrl = story.storyUrl[_currentIndex];
        }

        // Create a message
        final message = {
          'message': _messageController.text.trim(),
          'storyUrl': storyUrl, // Add storyUrl if it exists, otherwise null
        };

        await _chatService.sendMessage(story.userUid, message);
        _messageController.clear();
        _showMessageSentNotification();

        _sendMessageTimer?.cancel();
        _sendMessageTimer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isPaused = false;
            });
            controller.play();
          }
        });
      } catch (e) {
        Get.snackbar('Error', 'Failed to send message: $e');
      }
    }
  }

  void _showMessageSentNotification() {
    if (mounted) {
      setState(() {
        _showMessageSent = true;
      });
    }
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showMessageSent = false;
        });
      }
    });
  }

  String _timeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    controller.pause();
    setState(() {
      _isPaused = true;
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    // Keep the story paused during a long press and move
    controller.pause();
    setState(() {
      _isPaused = true;
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    // Resume the story when the user releases the long press
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteStory();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStory() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        setState(() {
          _isDeleting = true;
        });

        final currentStoryUrl = story.storyUrl[_currentIndex];

        // Delete the specific story URL from Firestore
        await FirebaseFirestore.instance
            .collection('story')
            .doc(currentUser.uid)
            .update({
          'storyUrl': FieldValue.arrayRemove([currentStoryUrl]),
        });

        // Optionally, if you want to delete the entire story document if no URLs are left:
        DocumentSnapshot storyDoc = await FirebaseFirestore.instance
            .collection('story')
            .doc(currentUser.uid)
            .get();

        if ((storyDoc.data() as Map)['storyUrl'].isEmpty) {
          await FirebaseFirestore.instance
              .collection('story')
              .doc(currentUser.uid)
              .delete();
        }

        Get.back(); // Exit the story view after deletion
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete story: $e');
      } finally {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _navigateToProfile(String userId) async {
    // Pause the story when navigating away
    controller.pause();
    setState(() {
      _isPaused = true;
    });

    // Navigate to ViewProfileScreen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewProfileScreen(userId: userId),
      ),
    );

    // Resume the story when coming back
    if (mounted) {
      setState(() {
        _isPaused = false;
      });
      controller.play();
    }
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
  void dispose() {
    _sendMessageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Ensure that story has a createdAt field
    DateTime? storyCreatedAt;
    final createdAt = story.createdAt;
    if (createdAt != null) {
      storyCreatedAt = createdAt.toDate();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          final dx = details.globalPosition.dx;

          setState(() {
            // Right tap: Go to the next story if not on the last one
            if (dx > width / 2) {
              if (_currentIndex < storyItems.length - 1) {
                // Move to the next story if there is one
                _currentIndex++;
                controller.next();
              } else {
                // Only exit when on the last story
                print("Reached the last story. Exiting...");
                Get.back();
              }
            } else {
              // Left tap: Go to the previous story if not on the first one
              if (_currentIndex > 0) {
                _currentIndex--;
                controller.previous();
              }
            }

            // Debugging outputs for better visibility
            print('Current Index: $_currentIndex');
            print('Story Count: ${storyItems.length}');
          });
        },
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onLongPressMoveUpdate: _onLongPressMoveUpdate,
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
                top: 5,
                left: 5,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.black.withOpacity(0),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (story.userUrl.isNotEmpty)
                          GestureDetector(
                            onTap: () => _navigateToProfile(story.userUid),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(story.userUrl),
                              radius: 16,
                            ),
                          ),
                        if (story.userUrl.isNotEmpty) SizedBox(width: 8),
                        if (story.userName.isNotEmpty)
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _navigateToProfile(story.userUid),
                                  child: Text(
                                    story.userName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (storyCreatedAt != null)
                                  Text(
                                    _timeAgo(storyCreatedAt!),
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        Spacer(),
                        if (currentUser != null &&
                            currentUser.uid == story.userUid)
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(),
                                    child: IconButton(
                                      icon: Icon(Icons.visibility,
                                          color: Colors.white),
                                      onPressed: _viewViewerList,
                                      tooltip: 'Viewers',
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 9.0),
                                    child: IconButton(
                                      icon: Icon(
                                          Icons.delete, color: Colors.white),
                                      onPressed: () {
                                        if (!_isDeleting) {
                                          _showDeleteConfirmationDialog();
                                        }
                                      },
                                    ),
                                  ),
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
                top: 67,
                right: 16,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _exitStoryView,
                    tooltip: 'Close',
                  ),
                ),
              ),
            Positioned(
              bottom: 15,
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
                      fillColor: _isTextFieldFocused ? Colors.grey[850] : Colors
                          .transparent,
                      filled: true,
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: _isTextFieldFocused ? Colors.amber : Colors
                              .white,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.amber, width: 1),
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
                  if (_messageController.text
                      .trim()
                      .isNotEmpty) {
                    _sendMessage();
                  }
                },
              ),
            ),
            if (_showMessageSent)
              Center(
                child: AnimatedOpacity(
                  opacity: _showMessageSent ? 1.0 : 0.0,
                  duration: Duration(seconds: 1),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Message sent!',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}