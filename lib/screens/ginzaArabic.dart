import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'GinzaArabicBookScreen.dart';
import 'GinzaArabicSearchScreen.dart';

class GinzaArabicScreen extends StatefulWidget {
  @override
  _GinzaArabicScreenState createState() => _GinzaArabicScreenState();
}

class _GinzaArabicScreenState extends State<GinzaArabicScreen> {
  List<dynamic> books = [];
  String? selectedBook;
  String? selectedChapter;
  List<dynamic>? verses;
  List<String> versesToCopy = [];
  bool isCopyButtonVisible = false;
  Set<String> selectedVerses = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

    _loadSavedState();
  }

  void _loadSavedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final savedScrollPosition = prefs.getDouble('scrollPosition') ?? 0;
    final savedBook = prefs.getString('selectedBook');
    final savedChapter = prefs.getString('selectedChapter');

    if (books.isNotEmpty) {
      var book = books.firstWhere((book) => book['book_name'] == savedBook, orElse: () => null);

      if (book != null) {
        var chapter = book['chapters'].firstWhere((chapter) => chapter['chapter_name'] == savedChapter, orElse: () => null);

        if (chapter != null) {
          setState(() {
            selectedBook = savedBook;
            selectedChapter = savedChapter;
            verses = chapter['verses'];
          });
        } else {
          setState(() {
            selectedBook = book['book_name'];
            selectedChapter = book['chapters'][0]['chapter_name'];
            verses = book['chapters'][0]['verses'];
          });
        }
      } else {
        setState(() {
          selectedBook = books[0]['book_name'];
          selectedChapter = books[0]['chapters'][0]['chapter_name'];
          verses = books[0]['chapters'][0]['verses'];
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSavedPosition(savedScrollPosition);
    });
  }

  void _scrollToSavedPosition(double savedScrollPosition) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        savedScrollPosition,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            savedScrollPosition,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _saveCurrentState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedBook', selectedBook ?? '');
    await prefs.setString('selectedChapter', selectedChapter ?? '');
    await prefs.setDouble('scrollPosition', _scrollController.position.pixels);
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
          versesToCopy.clear();
          isCopyButtonVisible = false;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
          });
        }
      }
    });
  }

  void _navigateToPreviousChapter() {
    int bookIndex = books.indexWhere((book) => book['book_name'] == selectedBook);
    int chapterIndex = books[bookIndex]['chapters'].indexWhere((chapter) => chapter['chapter_name'] == selectedChapter);

    if (chapterIndex > 0) {
      setState(() {
        selectedChapter = books[bookIndex]['chapters'][chapterIndex - 1]['chapter_name'];
        verses = books[bookIndex]['chapters'][chapterIndex - 1]['verses'];
      });
    } else if (bookIndex > 0) {
      setState(() {
        bookIndex--;
        selectedBook = books[bookIndex]['book_name'];
        selectedChapter = books[bookIndex]['chapters'].last['chapter_name'];
        verses = books[bookIndex]['chapters'].last['verses'];
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
      _saveCurrentState();
    });
  }

  void _navigateToNextChapter() {
    int bookIndex = books.indexWhere((book) => book['book_name'] == selectedBook);
    int chapterIndex = books[bookIndex]['chapters'].indexWhere((chapter) => chapter['chapter_name'] == selectedChapter);

    if (chapterIndex < books[bookIndex]['chapters'].length - 1) {
      setState(() {
        selectedChapter = books[bookIndex]['chapters'][chapterIndex + 1]['chapter_name'];
        verses = books[bookIndex]['chapters'][chapterIndex + 1]['verses'];
      });
    } else if (bookIndex < books.length - 1) {
      setState(() {
        bookIndex++;
        selectedBook = books[bookIndex]['book_name'];
        selectedChapter = books[bookIndex]['chapters'][0]['chapter_name'];
        verses = books[bookIndex]['chapters'][0]['verses'];
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
      _saveCurrentState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveCurrentState();
        return true;
      },
      child: Scaffold(
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
                      selectedBook ?? 'Select a Book',
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
                  _copyVerses();
                },
              ),
            IconButton(
              icon: Icon(Icons.book, color: Colors.black),
              onPressed: () => _navigateToBookScreen(context),
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: _navigateToSearchScreen,
            ),
          ],
        ),
        body: verses != null
            ? Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: verses!.length,
                itemBuilder: (context, index) {
                  final verse = verses![index];
                  final verseNumber = verse['verse_number'].toString();
                  final isSelected = selectedVerses.contains(verseNumber);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedVerses.remove(verseNumber);
                          if (selectedVerses.isEmpty) {
                            isCopyButtonVisible = false;
                          }
                        } else {
                          selectedVerses.add(verseNumber);
                          isCopyButtonVisible = true;
                        }
                      });
                    },
                    child: DottedBorder(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      strokeWidth: 1.5,
                      borderType: BorderType.Rect,
                      dashPattern: [4, 4],
                      radius: Radius.circular(4),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "$verseNumber: ${verse['text']}",
                          style: TextStyle(fontSize: 18), // Increased font size for verse text
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Adjusted position using SizedBox
            SizedBox(height: 10), // Add space before navigation buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 15), // Additional padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 40),
                    color: Colors.amber,// Increased size for chapter navigation button
                    onPressed: _navigateToPreviousChapter,
                  ),
                  Text(
                    selectedChapter ?? '',
                    style: TextStyle(fontSize: 22), // Optionally increase size for chapter title
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward, size: 40),
                    color: Colors.amber,// Increased size for chapter navigation button
                    onPressed: _navigateToNextChapter,
                  ),
                ],
              ),
            ),
          ],
        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _copyVerses() {
    String versesText = selectedVerses.map((verseNumber) {
      final verse = verses!.firstWhere((v) => v['verse_number'].toString() == verseNumber);
      // Format for Arabic direction
      return "الكتاب: $selectedBook، الفصل: $selectedChapter\nالآية ${verse['verse_number']}: ${verse['text']}";
    }).join('\n\n'); // Added spacing between verses

    // Set clipboard data with RTL support
    Clipboard.setData(ClipboardData(text: versesText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم نسخ ${selectedVerses.length} آيات إلى الحافظة!')),
      );

      setState(() {
        selectedVerses.clear();
        isCopyButtonVisible = false; // Hide copy button after copying
      });
    });
  }

  void _navigateToSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GinzaArabicSearchScreen(
          books: books,
          onVerseSelected: (bookName, chapterName, verseNumber) {
            setState(() {
              selectedBook = bookName;
              selectedChapter = chapterName;
              var book = books.firstWhere((book) => book['book_name'] == bookName);
              var chapter = book['chapters'].firstWhere((chapter) => chapter['chapter_name'] == chapterName);
              verses = chapter['verses'];
              selectedVerses = verseNumber as Set<String>;
            });
          },
        ),
      ),
    );
  }



  void _navigateToBookScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GinzaArabicBookScreen(
        books: books,
        selectedBook: selectedBook!,
        selectedChapter: selectedChapter!,
        onBookAndChapterSelected: onBookAndChapterSelected,
      )),
    );
  }
}
