import 'package:the_mandean_app/models/chapter.dart';

class Book{
  final String title;
  final List<Chapter> chapters;

  Book({
    required this.title,
    required this.chapters,
  });
}