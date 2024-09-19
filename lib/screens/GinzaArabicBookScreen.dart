import 'package:flutter/material.dart';

class GinzaArabicBookScreen extends StatefulWidget {
  final List<dynamic> books;
  final Function(String, String) onBookAndChapterSelected;

  GinzaArabicBookScreen({required this.books, required this.onBookAndChapterSelected});

  @override
  _GinzaArabicBookScreenState createState() => _GinzaArabicBookScreenState();
}

class _GinzaArabicBookScreenState extends State<GinzaArabicBookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حدد الكتاب والفصل'),
        backgroundColor: Colors.white, // Set the app bar background to white
      ),
      body: ListView.builder(
        itemCount: widget.books.length,
        itemBuilder: (context, bookIndex) {
          var book = widget.books[bookIndex];
          return ExpansionTile(
            title: Text(
              book['book_name'],
              style: TextStyle(color: Colors.black),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8, // Increased to 8 columns for smaller squares
                    crossAxisSpacing: 2.0, // Reduced spacing for a tighter fit
                    mainAxisSpacing: 2.0, // Reduced spacing for a tighter fit
                    childAspectRatio: 1, // Keep squares aspect ratio
                  ),
                  itemCount: book['chapters'].length,
                  itemBuilder: (context, chapterIndex) {
                    var chapter = book['chapters'][chapterIndex];
                    return GestureDetector(
                      onTap: () {
                        widget.onBookAndChapterSelected(
                          book['book_name'],
                          chapter['chapter_name'],
                        );
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 30.0, // Smaller width for the squares
                        height: 30.0, // Smaller height for the squares
                        decoration: BoxDecoration(
                          color: Colors.white, // Use white background for the chapter cards
                          borderRadius: BorderRadius.circular(5.0), // Smaller border radius for a cleaner look
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${chapter['chapter_number']}',
                          style: TextStyle(fontSize: 15.0, color: Colors.black), // Smaller font size
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
