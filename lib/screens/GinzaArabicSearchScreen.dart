import 'dart:convert';
import 'package:flutter/material.dart';

class GinzaArabicSearchScreen extends StatefulWidget {
  final List<dynamic> books;
  final Function(String bookName, String chapterName, String verseNumber) onVerseSelected;

  GinzaArabicSearchScreen({required this.books, required this.onVerseSelected});

  @override
  _GinzaArabicSearchScreenState createState() => _GinzaArabicSearchScreenState();
}

class _GinzaArabicSearchScreenState extends State<GinzaArabicSearchScreen> {
  List<Map<String, dynamic>> searchResults = [];
  TextEditingController searchController = TextEditingController();

  void _search(String keyword) {
    List<Map<String, dynamic>> results = [];
    for (var book in widget.books) {
      for (var chapter in book['chapters']) {
        for (var verse in chapter['verses']) {
          if (verse['text'].toLowerCase().contains(keyword.toLowerCase())) {
            results.add({
              'book_name': book['book_name'],
              'chapter_name': chapter['chapter_name'],
              'verse_number': verse['verse_number'].toString(), // Ensure it's a string
              'text': verse['text']
            });
          }
        }
      }
    }

    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Enter keyword',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _search(searchController.text);
                  },
                ),
              ),
            ),
            Expanded(
              child: searchResults.isEmpty
                  ? Center(child: Text('No verses found.')) // Display message if no results
                  : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  String keyword = searchController.text;
                  String verseText = result['text'];

                  // Split the verse into parts to highlight the keyword
                  List<TextSpan> spans = [];
                  int start = 0;
                  int keywordIndex;

                  while ((keywordIndex = verseText.toLowerCase().indexOf(keyword.toLowerCase(), start)) != -1) {
                    if (keywordIndex > start) {
                      spans.add(TextSpan(text: verseText.substring(start, keywordIndex)));
                    }
                    spans.add(
                      TextSpan(
                        text: verseText.substring(keywordIndex, keywordIndex + keyword.length),
                        style: TextStyle(backgroundColor: Colors.yellow), // Highlighting
                      ),
                    );
                    start = keywordIndex + keyword.length;
                  }
                  if (start < verseText.length) {
                    spans.add(TextSpan(text: verseText.substring(start)));
                  }

                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(text: '${result['verse_number']}: '),
                          ...spans,
                        ],
                      ),
                    ),
                    subtitle: Text('${result['book_name']} - ${result['chapter_name']}'),
                    onTap: () {
                      widget.onVerseSelected(result['book_name'], result['chapter_name'], result['verse_number']);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
