import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as rootBundle;

class BookOfJohnScreen extends StatefulWidget {
  @override
  _BookOfJohnScreenState createState() => _BookOfJohnScreenState();
}

class _BookOfJohnScreenState extends State<BookOfJohnScreen> {
  late Future<List<Chapter>> _chaptersFuture;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = loadChapters();
  }

  Future<List<Chapter>> loadChapters() async {
    try {
      final jsonString = await rootBundle.rootBundle.loadString('assets/ginzas/MandaeanBookOfJohn.json');
      final jsonData = json.decode(jsonString);

      if (jsonData['chapters'] != null) {
        return (jsonData['chapters'] as List)
            .map((chapter) => Chapter.fromJson(chapter))
            .toList();
      } else {
        throw Exception("No chapters found");
      }
    } catch (e) {
      print("Error loading chapters: $e");
      return [];  // Return an empty list if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Of John'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Chapter>>(
        future: _chaptersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading chapters'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chapters available'));
          } else {
            final chapters = snapshot.data!;
            return ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ChapterWidget(chapter: chapter);
              },
            );
          }
        },
      ),
    );
  }
}

class Verse {
  final int verseNumber;
  final String verseText;

  Verse({required this.verseNumber, required this.verseText});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verseNumber: json['verseNumber'],
      verseText: json['verseText'] ?? json['text'],  // Handling both 'verseText' and 'text' keys
    );
  }
}

class Chapter {
  final String chapterName;
  final int chapterNumber;
  final List<Verse> verses;

  Chapter({required this.chapterName, required this.chapterNumber, required this.verses});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterName: json['chapterName'] ?? '',  // Defaulting to empty string if not present
      chapterNumber: json['chapterNumber'],
      verses: (json['verses'] as List).map((verse) => Verse.fromJson(verse)).toList(),
    );
  }
}

class ChapterWidget extends StatelessWidget {
  final Chapter chapter;

  ChapterWidget({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,  // Center the chapter name
        children: [
          Text(
            chapter.chapterName,
            style: TextStyle(
              fontSize: 28,  // Increase the font size of the chapter name
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,  // Center the chapter name
          ),
          SizedBox(height: 10),
          ...chapter.verses.map((verse) {
            return VerseWidget(verse: verse);
          }).toList(),
        ],
      ),
    );
  }
}

class VerseWidget extends StatefulWidget {
  final Verse verse;

  VerseWidget({required this.verse});

  @override
  _VerseWidgetState createState() => _VerseWidgetState();
}

class _VerseWidgetState extends State<VerseWidget> {
  bool isHighlighted = false;

  void toggleHighlight() {
    setState(() {
      isHighlighted = !isHighlighted;
    });
  }

  void saveVerse() {
    // Implement saving functionality here
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        toggleHighlight();
        saveVerse();
      },
      child: Container(
        color: isHighlighted ? Colors.yellow[100] : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8.0),  // Add padding for better spacing
        child: SelectableText(
          "${widget.verse.verseNumber}. ${widget.verse.verseText}",
          style: TextStyle(
            fontSize: 20,  // Increase the font size of the verse text
            color: Colors.black,  // Use black color for verse text
          ),
          toolbarOptions: ToolbarOptions(copy: true),
          textAlign: TextAlign.center,  // Center the verse text
        ),
      ),
    );
  }
}
