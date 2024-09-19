import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_mandean_app/calendar/meeting.dart';

class MeetingDataSource extends CalendarDataSource {
  final bool isEnglish;

  MeetingDataSource(List<Meeting> source, this.isEnglish) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    final meeting = appointments![index] as Meeting;
    return meeting.getTitle(isEnglish);
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
