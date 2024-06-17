import 'package:the_mandean_app/models/verse.dart';

class Chapter {
  final int title;
  final List<Verse> verses;
  Chapter({
    required this.title,
    required this.verses,
});
}