import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart'; // Import the dotted_border package
import 'GinzaArabicBookScreen.dart';
import 'GinzaArabicSearchScreen.dart'; // Import the search screen

class GinzaArabicScreen extends StatefulWidget {
  @override
  _GinzaArabicScreenState createState() => _GinzaArabicScreenState();
}

class _GinzaArabicScreenState extends State<GinzaArabicScreen> {
  List<dynamic> books = [];
  String? selectedBook;
  String? selectedChapter;
  List<dynamic>? verses;
  String? verseToCopy;
  bool isCopyButtonVisible = false;
  String? selectedVerse;

  // Add ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the ScrollController
    super.dispose();
  }

  Future<void> loadBooks() async {
    String jsonString = await rootBundle.loadString('assets/ginzas/ginzaArabic.json');
    final data = json.decode(jsonString);
    setState(() {
      books = data['books'];
      if (books.isNotEmpty) {
        selectedBook = books[0]['book_name'];
        selectedChapter = books[0]['chapters'][0]['chapter_name'];
        verses = books[0]['chapters'][0]['verses'];
      }
    });
  }

  void onBookAndChapterSelected(String bookName, String chapterName) {
    setState(() {
      selectedBook = bookName;
      var book = books.firstWhere((book) => book['book_name'] == bookName, orElse: () => null);
      if (book != null) {
        var chapter = book['chapters'].firstWhere((chapter) => chapter['chapter_name'] == chapterName, orElse: () => null);
        if (chapter != null) {
          selectedChapter = chapterName;
          verses = chapter['verses'];
          verseToCopy = null;
          isCopyButtonVisible = false;
          selectedVerse = null;

          // Scroll to the top when the chapter changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.jumpTo(0);
          });
        } else {
          // Handle chapter not found
          print('Chapter not found');
        }
      } else {
        // Handle book not found
        print('Book not found');
      }
    });
  }

  void _copyVerse(String verseNumber, String verseText) {
    Clipboard.setData(ClipboardData(text: '$selectedBook - $selectedChapter\n$verseNumber: $verseText')).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard')),
      );
      setState(() {
        isCopyButtonVisible = false;
        selectedVerse = null;
      });
    });
  }

  void _navigateToSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GinzaArabicSearchScreen(
          books: books,
          onVerseSelected: (String bookName, String chapterName, String verseNumber) {
            onBookAndChapterSelected(bookName, chapterName);
            setState(() {
              selectedVerse = verseNumber; // Highlight the selected verse
              verseToCopy = '$verseNumber: ${verses!.firstWhere((verse) => verse['verse_number'].toString() == verseNumber)['text']}';
              isCopyButtonVisible = true;
            });
          },
        ),
      ),
    );
  }

  void _navigateToPreviousChapter() {
    int bookIndex = books.indexWhere((book) => book['book_name'] == selectedBook);
    int chapterIndex = books[bookIndex]['chapters'].indexWhere((chapter) => chapter['chapter_name'] == selectedChapter);

    if (chapterIndex > 0) {
      // Move to the previous chapter within the same book
      setState(() {
        selectedChapter = books[bookIndex]['chapters'][chapterIndex - 1]['chapter_name'];
        verses = books[bookIndex]['chapters'][chapterIndex - 1]['verses'];
      });
    } else if (bookIndex > 0) {
      // Move to the last chapter of the previous book
      setState(() {
        bookIndex--;
        selectedBook = books[bookIndex]['book_name'];
        selectedChapter = books[bookIndex]['chapters'].last['chapter_name'];
        verses = books[bookIndex]['chapters'].last['verses'];
      });
    }

    // Scroll to the top after changing chapters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
  }

  void _navigateToNextChapter() {
    int bookIndex = books.indexWhere((book) => book['book_name'] == selectedBook);
    int chapterIndex = books[bookIndex]['chapters'].indexWhere((chapter) => chapter['chapter_name'] == selectedChapter);

    if (chapterIndex < books[bookIndex]['chapters'].length - 1) {
      // Move to the next chapter within the same book
      setState(() {
        selectedChapter = books[bookIndex]['chapters'][chapterIndex + 1]['chapter_name'];
        verses = books[bookIndex]['chapters'][chapterIndex + 1]['verses'];
      });
    } else if (bookIndex < books.length - 1) {
      // Move to the first chapter of the next book
      setState(() {
        bookIndex++;
        selectedBook = books[bookIndex]['book_name'];
        selectedChapter = books[bookIndex]['chapters'][0]['chapter_name'];
        verses = books[bookIndex]['chapters'][0]['verses'];
      });
    }

    // Scroll to the top after changing chapters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () => _navigateToBookScreen(context),
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$selectedBook - $selectedChapter',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (isCopyButtonVisible)
            IconButton(
              icon: Icon(Icons.copy, color: Colors.amber),
              onPressed: () {
                if (verseToCopy != null) {
                  final parts = verseToCopy!.split(': ');
                  _copyVerse(parts[0], parts[1]);
                }
              },
            ),
          IconButton(
            icon: Icon(Icons.book, color: Colors.black),
            onPressed: () => _navigateToBookScreen(context),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: _navigateToSearchScreen, // Call search navigation
          ),
        ],
      ),
      body: Stack(
        children: [
          verses != null
              ? ListView.builder(
            controller: _scrollController, // Use ScrollController
            itemCount: verses!.length,
            itemBuilder: (context, index) {
              final verse = verses![index];
              final isSelected = selectedVerse == verse['verse_number'].toString();
              return GestureDetector(
                onTap: () {
                  setState(() {
                    verseToCopy = isSelected ? null : '${verse['verse_number']}: ${verse['text']}';
                    isCopyButtonVisible = !isSelected;
                    selectedVerse = isSelected ? null : verse['verse_number'].toString();
                  });
                },
                child: DottedBorder(
                  color: isSelected ? Colors.amber : Colors.transparent,
                  strokeWidth: 1.5,
                  borderType: BorderType.Rect,
                  dashPattern: [4, 4], // Dotted border pattern
                  radius: Radius.circular(4),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Text(
                      '${verse['verse_number']}: ${verse['text']}',
                      style: TextStyle(
                        fontSize: 20, // Increase font size by 3px
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold text if selected
                        color: Colors.black, // Set text color to black
                      ),
                    ),
                  ),
                ),
              );
            },
          )
              : Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'previousButton', // Assign a unique Hero tag
              onPressed: _navigateToPreviousChapter,
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: Colors.amber),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'nextButton', // Assign a unique Hero tag
              onPressed: _navigateToNextChapter,
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_forward, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBookScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GinzaArabicBookScreen(
          books: books,
          onBookAndChapterSelected: onBookAndChapterSelected,
        ),
      ),
    );
  }
}
