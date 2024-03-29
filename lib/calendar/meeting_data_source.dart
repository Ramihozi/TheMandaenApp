import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_mandean_app/calendar/meeting.dart';

class MeetingDataSource extends CalendarDataSource{
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  bool isAllDay(int index){
    return appointments![index].isAllDay;
  }

}