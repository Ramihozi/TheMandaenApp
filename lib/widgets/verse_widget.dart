import 'package:flutter/material.dart';
import 'package:the_mandean_app/models/verse.dart';
import 'package:the_mandean_app/providers/main_provider.dart';
import 'package:provider/provider.dart';

class VerseWidget extends StatelessWidget {
  final Verse verse;
  final int index;

  const VerseWidget({
    super.key,
    required this.verse,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        // Determine if the verse is selected
        bool isSelected = mainProvider.selectedVerses.any((e) => e == verse);

        return ListTile(
          onTap: () {
            // Toggle the selection of the verse
            mainProvider.toggleVerse(verse: verse);
          },
          title: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(
                fontFamily: 'Merriweather',
                fontSize: 16, // Overall text size
              ),
              children: <TextSpan>[
                // TextSpan for chapter or verse number
                TextSpan(
                  text: verse.verse == 1 ? "${verse.chapter}" : "${verse.verse.toString()} ",
                  style: TextStyle(
                    fontSize: verse.verse == 1 ? 22 : 18, // Slightly smaller font sizes
                    fontWeight: verse.verse == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                // TextSpan for the verse text
                TextSpan(
                  text: " ${verse.text.trim()}",
                  style: TextStyle(
                    fontSize: 16, // Increased font size for verse text
                    decorationStyle: isSelected ? TextDecorationStyle.dotted : TextDecorationStyle.solid,
                    decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
