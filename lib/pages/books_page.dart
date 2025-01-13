import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/models/book.dart';
import 'package:the_mandean_app/models/chapter.dart';
import 'package:the_mandean_app/providers/main_provider.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BooksPage extends StatefulWidget {
  final int chapterIdx;
  final String bookIdx;

  const BooksPage({Key? key, required this.chapterIdx, required this.bookIdx}) : super(key: key);

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0.0; // Variable to store the scroll position

  @override
  void initState() {
    super.initState();
    _loadScrollPosition(); // Load the scroll position when the page is initialized
    _scrollController.addListener(() {
      _scrollPosition = _scrollController.position.pixels; // Update scroll position as it changes
    });
  }

  @override
  void dispose() {
    _saveScrollPosition(); // Save the scroll position when the page is disposed
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadScrollPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _scrollPosition = prefs.getDouble('scrollPosition') ?? 0.0; // Load scroll position from SharedPreferences
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollPosition); // Jump to the loaded scroll position
      });
    });
  }

  Future<void> _saveScrollPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scrollPosition', _scrollPosition); // Save scroll position to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    List<Book> books = mainProvider.books;
    Book? currentBook = mainProvider.books.firstWhere(
          (element) => element.title == mainProvider.currentVerse!.book,
      orElse: () => books.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Books"),
        backgroundColor: Colors.white,
      ),
      body: Consumer<MainProvider>(
        builder: (context, mainProvider, child) {
          return ExpandableNotifier(
            child: ListView.builder(
              controller: _scrollController, // Set the scroll controller to the ListView
              itemCount: books.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                Book book = books[index];
                return ListTile(
                  title: ExpandablePanel(
                    controller: ExpandableController(
                      initialExpanded: currentBook == book,
                    ),
                    collapsed: SizedBox.shrink(),
                    header: Container(
                      color: Colors.white,
                      child: Text(book.title),
                    ),
                    expanded: Wrap(
                      children: List.generate(
                        book.chapters.length,
                            (chapterIndex) {
                          Chapter chapter = book.chapters[chapterIndex];
                          return SizedBox(
                            height: 45,
                            width: 45,
                            child: GestureDetector(
                              onTap: () {
                                // Update the current verse and the current chapter index
                                int idx = mainProvider.verses.indexWhere(
                                      (element) => element.chapter == chapter.title && element.book == book.title,
                                );

                                // Update the mainProvider with the new current verse
                                if (idx != -1) {
                                  mainProvider.updateCurrentVerse(
                                    verse: mainProvider.verses[idx],
                                  );

                                  // Update the current chapter and book index
                                  mainProvider.currentChapterIndex = chapterIndex;
                                  mainProvider.currentBookIndex = index;

                                  // Optionally, notify listeners if needed
                                  mainProvider.notifyListeners();
                                }

                                // Pop the current screen
                                Get.back();
                              },
                              child: Card(
                                color: widget.chapterIdx == chapterIndex && widget.bookIdx == book.title
                                    ? Colors.white
                                    : Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.5),
                                ),
                                child: Center(
                                  child: Text(
                                    chapter.title.toString(),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}