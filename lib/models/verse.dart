

class Verse {
  final String book;
  final int chapter;
  final int verse;
  final String text;
  Verse({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });
  //Factory Method To Create a Verse Object From JSON Data
  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      book: json['book'],
      chapter: int.parse(json['chapter']),
      verse: int.parse(json['verse']),
      text: json['text'],
    );
  }
}