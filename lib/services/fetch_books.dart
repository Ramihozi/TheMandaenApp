import 'package:the_mandean_app/models/book.dart';
import 'package:the_mandean_app/models/chapter.dart';
import 'package:the_mandean_app/providers/main_provider.dart';
import 'package:the_mandean_app/models/verse.dart';

// Class responsible for fetching books basic on the provided verses

class FetchBooks {

  // Static Method To Execute THe Fetching Process
  static Future<void> execute({required MainProvider mainProvider}) async {
    List<Verse> verses = mainProvider.verses;

    // Extract Unique Book Titles and The List Of Verses
    List <String> bookTitles = verses.map((e) => e.book).toSet().toList();

    // Iterate Through each unique book title to organize chapters and verses

    for (var bookTitle in bookTitles) {
      // Filter Verses Based On The Current Book Title
      List<Verse>availableVerses =
          verses.where((v) => v.book == bookTitle).toList();

      // Extract unique chapter numbers from the filtered verses
      List<int> availableChapters =
          availableVerses.map((e) => e.chapter).toSet().toList();

      List<Chapter> chapters = [];

      // Iterate through each unique chapter number to organize verses
      for (var element in availableChapters) {
        Chapter chapter = Chapter(
            title: element,
            verses: availableVerses.where((v) => v.chapter == element).toList(),
        );

        chapters.add(chapter);

      }

      //Create a Book object for the current book title and its organized chapters
      Book book = Book(title: bookTitle, chapters: chapters);

      // Add the created Book to the mainProvider's list of books
      mainProvider.addBook(book: book);

    }

  }
}
