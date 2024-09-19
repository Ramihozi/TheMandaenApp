import 'dart:ui';

class Meeting {
  final String titleEn;
  final String titleAr;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final bool isAllDay;


  Meeting(this.titleEn, this.titleAr, this.startTime, this.endTime, this.color, this.isAllDay);

  String getTitle(bool isEnglish) => isEnglish ? titleEn : titleAr;
}
