import 'package:shared_preferences/shared_preferences.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:the_mandean_app/models/verse.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/pages/books_page.dart';
import 'package:the_mandean_app/pages/search_page.dart';
import 'package:the_mandean_app/providers/main_provider.dart';
import 'package:the_mandean_app/widgets/verse_widget.dart';

class GinzaScreen extends StatefulWidget {
  const GinzaScreen({super.key});

  @override
  State<GinzaScreen> createState() => _GinzaScreenState();
}

class _GinzaScreenState extends State<GinzaScreen> {
  static const String lastPositionKey = 'lastVersePosition';
  int? currentIndex;

  @override
  void initState() {
    super.initState();
    _loadLastPosition();

    // Listen for scroll changes and update the currentIndex
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    mainProvider.itemPositionsListener.itemPositions.addListener(() {
      final positions = mainProvider.itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        // Get the first visible item's index
        currentIndex = positions.first.index;
        if (mounted) {
          setState(() {});  // Trigger rebuild to update the title
        }
      }
    });
  }

  Future<void> _loadLastPosition() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? lastIndex = prefs.getInt(lastPositionKey);

    // Load the current chapter verses
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    if (lastIndex != null && lastIndex < mainProvider.currentChapterVerses.length) {
      Future.delayed(
        const Duration(milliseconds: 100),
            () {
          mainProvider.scrollToIndex(index: lastIndex);
        },
      );
    }
  }

  // Save current position to SharedPreferences
  Future<void> _saveLastPosition() async {
    if (currentIndex != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(lastPositionKey, currentIndex!);
    }
  }

  @override
  void dispose() {
    // Save current position before the widget is disposed
    _saveLastPosition();
    super.dispose();
  }

  // Process selected verses to create a formatted string
  String formattedSelectedVerses({required List<Verse> verses}) {
    String result = verses
        .map((e) => " [${e.book} ${e.chapter}:${e.verse}] ${e.text.trim()}")
        .join();

    return "$result";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        List<Verse> currentChapterVerses = mainProvider.currentChapterVerses;
        Verse? currentVerse = currentIndex != null ? currentChapterVerses[currentIndex!] : null;
        bool isSelected = mainProvider.selectedVerses.isNotEmpty;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: currentVerse == null || isSelected
                  ? null
                  : FittedBox(
                fit: BoxFit.scaleDown,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => BooksPage(
                      chapterIdx: currentVerse.chapter,
                      bookIdx: currentVerse.book.toString(),
                    ), transition: Transition.leftToRight);
                  },
                  child: Text(
                    currentVerse.book,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.to(() => BooksPage(
                      chapterIdx: currentVerse?.chapter ?? 0,
                      bookIdx: currentVerse?.book.toString() ?? '',
                    ), transition: Transition.leftToRight);
                  },
                  icon: const Icon(
                    Icons.book_rounded,
                    color: Colors.black,
                  ),
                ),
                if (isSelected)
                  IconButton(
                    onPressed: () async {
                      String string = formattedSelectedVerses(verses: mainProvider.selectedVerses);
                      await FlutterClipboard.copy(string).then(
                            (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Verses copied to clipboard!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          mainProvider.clearSelectedVerses();
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: Colors.black,
                    ),
                  ),
                if (!isSelected)
                  IconButton(
                    onPressed: () async {
                      Get.to(() => SearchPage(verses: currentChapterVerses), transition: Transition.rightToLeft);
                    },
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemCount: currentChapterVerses.length,
                    itemBuilder: (context, index) {
                      Verse verse = currentChapterVerses[index];
                      return VerseWidget(verse: verse, index: index);
                    },
                    itemScrollController: mainProvider.itemScrollController,
                    itemPositionsListener: mainProvider.itemPositionsListener,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0), // Add padding around the icon
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 40),
                        color: Colors.amber,// Set a larger size
                        onPressed: () {
                          mainProvider.previousChapter();
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0), // Add padding around the icon
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward, size: 40),
                        color: Colors.amber,// Set a larger size
                        onPressed: () {
                          mainProvider.nextChapter(); // Move to the next chapter

                          // Check if verses are loaded before scrolling
                          if (mainProvider.currentChapterVerses.isNotEmpty) {
                            // Jump instantly to the top of the new chapter
                            mainProvider.itemScrollController.jumpTo(
                              index: 0, // Jump to the top of the chapter
                            );
                          } else {
                            print("No verses available for the next chapter."); // Debugging log
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
