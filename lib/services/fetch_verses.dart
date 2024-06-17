import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:the_mandean_app/models/verse.dart';
import 'package:the_mandean_app/providers/main_provider.dart';

// Class Responsible for fetching verses from a JSON file

class FetchVerses {

  // Static method to execute tje fetching process
  static Future<void> execute({required MainProvider mainProvider}) async {
    //Load THe Json File Content As A String From THe Assets Folder
    String jsonString = await rootBundle.loadString('assets/ginzas/al-saadiENG.json');

    // Decode The JSON String Into A list Of Dynamic Objects

    List<dynamic> jsonList = json.decode(jsonString);

    // Loop Through Each JSON Object, Then Convert It To A Verse, And Add It To The Provider's List

    for (var json in jsonList) {
      mainProvider.addVerse(verse: Verse.fromJson(json));
    }
  }
}