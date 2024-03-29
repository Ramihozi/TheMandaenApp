import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_mandean_app/calendar/meeting.dart';
import 'package:the_mandean_app/calendar/meeting_data_source.dart';


class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting('Light Fasting (drashya)', startTime, endTime, Colors.amber, false));
    return meetings;
  }

  CalendarView calendarView = CalendarView.month;
  CalendarController calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: (){
                setState(() {
                  calendarView = CalendarView.month;
                  calendarController.view = calendarView;
                });
              }, child: Text("Month View")),
              OutlinedButton(onPressed: (){
                setState(() {
                  calendarView = CalendarView.week;
                  calendarController.view = calendarView;
                });
              }, child: Text("Week View")),
              OutlinedButton(onPressed: (){
                setState(() {
                  calendarView = CalendarView.day;
                  calendarController.view = calendarView;
                });
              }, child: Text("Day View")),
            ],
          ),
          Expanded(
          child: SfCalendar(
            view: calendarView,
            initialSelectedDate: DateTime.now(),
            controller: calendarController,
            cellBorderColor: Colors.transparent,
            dataSource: MeetingDataSource(_getDataSource()),
            selectionDecoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.amber, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              shape: BoxShape.rectangle
            ),
            monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                showAgenda: true,
            ),
            todayHighlightColor: Colors.amber,
            showNavigationArrow: true,
          ),
          ),
        ],
      ),
    );

  }



}

