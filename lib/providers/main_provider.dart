import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_mandean_app/models/book.dart';
import 'package:the_mandean_app/models/verse.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MainProvider extends ChangeNotifier {
  // Controllers and Listeners for managing scroll positions and items
  ItemScrollController itemScrollController = ItemScrollController();
  ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();

  // List to store Verse objects
  List<Verse> verses = [];

  // List to store Book objects
  List<Book> books = [];

  // Variable to store the current Verse
  Verse? currentVerse;

  // Variables to store the current chapter and book indices
  int currentChapterIndex = 0; // Tracks the current chapter index
  int currentBookIndex = 0;    // Tracks the current book index

  // Initialize the provider and load saved data
  MainProvider() {
    _loadSavedPosition();
  }

  // Method to add a Verse to the list and notify listeners
  void addVerse({required Verse verse}) {
    verses.add(verse);
    notifyListeners();
  }

  // Method to add a Book to the list and notify listeners
  void addBook({required Book book}) {
    books.add(book);
    notifyListeners();
  }

  // Method to update the current Verse and notify listeners
  void updateCurrentVerse({required Verse verse}) {
    currentVerse = verse;
    notifyListeners();
  }

  List<Verse> get currentChapterVerses {
    if (books.isEmpty || currentBookIndex >= books.length) return [];
    if (currentChapterIndex >= books[currentBookIndex].chapters.length) return [];
    return verses.where((verse) =>
    verse.book == books[currentBookIndex].title &&
        verse.chapter == currentChapterIndex + 1).toList();
  }

  void nextChapter() {
    if (currentChapterIndex + 1 < books[currentBookIndex].chapters.length) {
      currentChapterIndex++;
    } else if (currentBookIndex + 1 < books.length) {
      currentBookIndex++;
      currentChapterIndex = 0; // Reset chapter index for the new book
    }
    _saveCurrentPosition();
    notifyListeners();
  }

  void previousChapter() {
    if (currentChapterIndex > 0) {
      currentChapterIndex--;
    } else if (currentBookIndex > 0) {
      currentBookIndex--;
      currentChapterIndex = books[currentBookIndex].chapters.length - 1; // Go to the last chapter of the previous book
    }
    _saveCurrentPosition();
    notifyListeners();
  }

  // Method to scroll to a specific index in the list and notify listeners
  void scrollToIndex({required int index}) {
    itemScrollController.scrollTo(
        index: index, duration: const Duration(milliseconds: 800));
    notifyListeners();
  }

  // List to store selected Verse objects
  List<Verse> selectedVerses = [];

  // Method to toggle the selection of a Verse and notify listeners
  void toggleVerse({required Verse verse}) {
    bool contains = selectedVerses.any((element) => element == verse);
    if (contains) {
      selectedVerses.remove(verse);
    } else {
      selectedVerses.add(verse);
    }
    notifyListeners();
  }

  // Method to clear the selected Verse list and notify listeners
  void clearSelectedVerses() {
    selectedVerses.clear();
    notifyListeners();
  }

  // Save the current position in SharedPreferences
  Future<void> _saveCurrentPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentBookIndex', currentBookIndex);
    await prefs.setInt('currentChapterIndex', currentChapterIndex);
  }

  // Load the saved position from SharedPreferences
  Future<void> _loadSavedPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentBookIndex = prefs.getInt('currentBookIndex') ?? 0;
    currentChapterIndex = prefs.getInt('currentChapterIndex') ?? 0;
    notifyListeners();
  }
}
