import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isXButtonVisible = true; // Track visibility of 'X' button
  int _currentIndex = 0;
  bool _isDeleting = false;

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
            caption: null, // Set to null as we'll handle text overlays separately
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
          await storiesController.markStoryAsViewed(story.userUid, currentStoryUrl, currentUser.uid);
        }
      } catch (e) {
        print('Failed to mark story as viewed: $e');
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Story'),
          content: Text('Are you sure you want to delete this story? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isDeleting = true;
      });
      await _deleteStory();
    }
  }

  Future<void> _deleteStory() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      if (_currentIndex >= 0 && _currentIndex < story.storyUrl.length) {
        final currentStoryUrl = story.storyUrl[_currentIndex];
        final storiesController = Get.find<StoriesController>();
        await storiesController.deleteStory(currentStoryUrl);
      }

      Get.back();
      Get.snackbar('Success', 'Story deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete story: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _toggleAppBarVisibility(bool visible) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isAppBarVisible = visible;
        });
      }
    });
  }

  void _exitStoryView() {
    if (!_isDeleting) {
      Get.back();
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    controller.pause();
    _toggleAppBarVisibility(false);
    setState(() {
      _isPaused = true;
      _isXButtonVisible = false; // Hide 'X' button on long press
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    controller.play();
    _toggleAppBarVisibility(true);
    setState(() {
      _isPaused = false;
      _isXButtonVisible = true; // Show 'X' button after long press
    });
  }

  void _viewViewerList() {
    if (story.storyUrl.isNotEmpty) {
      final currentStoryUrl = story.storyUrl[_currentIndex];
      Get.to(() => ViewerListScreen(storyUrl: currentStoryUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onTap: () {
          if (_isPaused) {
            controller.play();
            _isPaused = false;
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
                        if (currentUser != null && currentUser.uid == story.userUid)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility, color: Colors.white),
                                onPressed: _viewViewerList,
                                tooltip: 'Viewers',
                              ),
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
                      ],
                    ),
                  ),
                ),
              ),
            if (_isXButtonVisible)
              Positioned(
                top: 74, // Adjust this value to position the 'X' button below the timer bar
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: _exitStoryView,
                  tooltip: 'Close',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
