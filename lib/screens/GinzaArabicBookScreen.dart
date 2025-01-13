import 'package:flutter/material.dart';

class GinzaArabicBookScreen extends StatelessWidget {
  final List<dynamic> books;
  final String selectedBook;
  final String selectedChapter;
  final Function(String, String) onBookAndChapterSelected;

  GinzaArabicBookScreen({
    required this.books,
    required this.selectedBook,
    required this.selectedChapter,
    required this.onBookAndChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Book and Chapter'),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ExpansionTile(
            title: Text(book['book_name']),
            initiallyExpanded: book['book_name'] == selectedBook,
            children: book['chapters'].map<Widget>((chapter) {
              return ListTile(
                title: Text(chapter['chapter_name']),
                selected: chapter['chapter_name'] == selectedChapter,
                onTap: () {
                  // Call the callback function to update the selected book and chapter
                  onBookAndChapterSelected(book['book_name'], chapter['chapter_name']);
                  Navigator.pop(context); // Go back to the previous screen
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
