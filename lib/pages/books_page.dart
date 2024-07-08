import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/models/book.dart';
import 'package:the_mandean_app/models/chapter.dart';
import 'package:the_mandean_app/providers/main_provider.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:expandable/expandable.dart';

class BooksPage extends StatefulWidget {
  final int chapterIdx;
  final String bookIdx;

  const BooksPage({Key? key, required this.chapterIdx, required this.bookIdx}) : super(key: key);

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  // AutoScrollController for automatic scrolling to the selected book
  final AutoScrollController _autoScrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    List<Book> books = mainProvider.books;
    Book? currentBook = mainProvider.books.firstWhere((element) => element.title == mainProvider.currentVerse!.book, orElse: () => books.first);

    // Finding the index of the current book and scrolling to it
    int index = books.indexOf(currentBook);
    _autoScrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: Duration(milliseconds: (10 * books.length)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Books"),
        backgroundColor: Colors.white, // Set background color of the app bar to white
      ),
      body: Consumer<MainProvider>(
        builder: (context, mainProvider, child) {
          return ExpandableNotifier(
            child: ListView.builder(
              itemCount: books.length,
              physics: BouncingScrollPhysics(),
              controller: _autoScrollController,
              itemBuilder: (context, index) {
                Book book = books[index];
                return AutoScrollTag(
                  key: ValueKey(index),
                  controller: _autoScrollController,
                  index: index,
                  child: ListTile(
                    title: ExpandablePanel(
                      controller: ExpandableController(
                        initialExpanded: currentBook == book,
                      ),
                      collapsed: SizedBox.shrink(),
                      header: Container(
                        color: Colors.white, // Set background color of the header to white
                        child: Text(book.title),
                      ),
                      expanded: Wrap(
                        children: List.generate(
                          book.chapters.length,
                              (index) {
                            Chapter chapter = book.chapters[index];
                            return SizedBox(
                              height: 45,
                              width: 45,
                              child: GestureDetector(
                                onTap: () {
                                  int idx = mainProvider.verses.indexWhere(
                                        (element) =>
                                    element.chapter == chapter.title &&
                                        element.book == book.title,
                                  );
                                  mainProvider.updateCurrentVerse(
                                    verse: mainProvider.verses.firstWhere(
                                          (element) =>
                                      element.chapter == chapter.title &&
                                          element.book == book.title,
                                    ),
                                  );
                                  mainProvider.scrollToIndex(index: idx);
                                  Get.back();
                                },
                                child: Card(
                                  color: chapter.title == widget.chapterIdx &&
                                      widget.bookIdx == book.title
                                      ? Colors.white // Set background color to white when condition is true
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
