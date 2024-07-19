
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
  late CalendarView _calendarView;
  late CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarView = CalendarView.month;
    _calendarController = CalendarController();
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];


      final DateTime startTime = DateTime(2024, 1, 5, 0, 0, 0);
    final DateTime startTime2 = DateTime(2024, 1, 13, 0, 0, 0);
    final DateTime startTime3 = DateTime(2024, 1, 18, 0, 0, 0);
    final DateTime startTime4 = DateTime(2024, 2, 12, 0, 0, 0);
    final DateTime startTime5 = DateTime(2024, 3, 4, 0, 0, 0);
    final DateTime startTime6 = DateTime(2024, 3, 8, 0, 0, 0);
    final DateTime startTime7=  DateTime(2024, 3, 9, 0, 0, 0);
    final DateTime startTime8 = DateTime(2024, 3, 10, 0, 0, 0);
    final DateTime startTime10 = DateTime(2024, 3, 12, 0, 0, 0);
    final DateTime startTime11 = DateTime(2024, 3, 13, 0, 0, 0);
    final DateTime startTime12 = DateTime(2024, 3, 14, 0, 0, 0);
    final DateTime startTime13 = DateTime(2024, 3, 15, 0, 0, 0);
    final DateTime startTime14 = DateTime(2024, 3, 16, 0, 0, 0);
    final DateTime startTime15 = DateTime(2024, 3, 17, 0, 0, 0);
    final DateTime startTime16 = DateTime(2024, 3, 18, 0, 0, 0);
    final DateTime startTime17 = DateTime(2024, 4, 17, 0, 0, 0);
    final DateTime startTime18 = DateTime(2024, 5, 17, 0, 0, 0);
    final DateTime startTime19 = DateTime(2024, 5, 18, 0, 0, 0);
    final DateTime startTime20 = DateTime(2024, 6, 16, 0, 0, 0);
    final DateTime startTime21 = DateTime(2024, 6, 24, 0, 0, 0);
    final DateTime startTime22 = DateTime(2024, 7, 9, 0, 0, 0);
    final DateTime startTime23 = DateTime(2024, 7, 13, 0, 0, 0);
    final DateTime startTime24 = DateTime(2024, 7, 14, 0, 0, 0);
    final DateTime startTime25 = DateTime(2024, 7, 15, 0, 0, 0);
    final DateTime startTime26 = DateTime(2024, 7, 16, 0, 0, 0);
    final DateTime startTime27 = DateTime(2024, 7, 17, 0, 0, 0);
    final DateTime startTime28 = DateTime(2024, 7, 18, 0, 0, 0);
    final DateTime startTime29 = DateTime(2024, 7, 19, 0, 0, 0);
    final DateTime startTime30 = DateTime(2024, 7, 20, 0, 0, 0);
    final DateTime startTime31 = DateTime(2024, 7, 21, 0, 0, 0);
    final DateTime startTime32 = DateTime(2024, 7, 22, 0, 0, 0);
    final DateTime startTime33 = DateTime(2024, 7, 23, 0, 0, 0);
    final DateTime startTime34 = DateTime(2024, 7, 24, 0, 0, 0);
    final DateTime startTime35 = DateTime(2024, 7, 25, 0, 0, 0);
    final DateTime startTime36 = DateTime(2024, 7, 26, 0, 0, 0);
    final DateTime startTime37 = DateTime(2024, 7, 27, 0, 0, 0);
    final DateTime startTime38 = DateTime(2024, 7, 28, 0, 0, 0);
    final DateTime startTime39 = DateTime(2024, 7, 29, 0, 0, 0);
    final DateTime startTime40 = DateTime(2024, 7, 30, 0, 0, 0);
    final DateTime startTime41 = DateTime(2024, 8, 6, 0, 0, 0);
    final DateTime startTime42 = DateTime(2024, 8, 15, 0, 0, 0);
    final DateTime startTime43 = DateTime(2024, 9, 8, 0, 0, 0);
    final DateTime startTime44 = DateTime(2024, 9, 13, 0, 0, 0);
    final DateTime startTime45 = DateTime(2024, 10, 14, 0, 0, 0);
    final DateTime startTime46 = DateTime(2024, 10, 15, 0, 0, 0);
    final DateTime startTime47 = DateTime(2024, 10, 16, 0, 0, 0);
    final DateTime startTime48 = DateTime(2024, 10, 17, 0, 0, 0);
    final DateTime startTime49 = DateTime(2024, 10, 31, 0, 0, 0);
    final DateTime startTime50 = DateTime(2024, 11, 13, 0, 0, 0);
    final DateTime startTime51 = DateTime(2024, 11, 18, 0, 0, 0);
    final DateTime startTime52 = DateTime(2024, 12, 13, 0, 0, 0);
    final DateTime startTime53 = DateTime(2024, 12, 21, 0, 0, 0);
    final DateTime startTime54 = DateTime(2024, 12, 27, 0, 0, 0);


    final DateTime endTime = startTime.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime2 = startTime2.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime3 = startTime3.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime4 = startTime4.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime5 = startTime5.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime6 = startTime6.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime7 = startTime7.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime8 = startTime8.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime10 = startTime10.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime11 = startTime11.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime12 = startTime12.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime13 = startTime13.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime14 = startTime14.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime15 = startTime15.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime16 = startTime16.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime17 = startTime17.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime18 = startTime18.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime19 = startTime19.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime20 = startTime20.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime21 = startTime21.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime22 = startTime22.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime23 = startTime23.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime24 = startTime24.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime25 = startTime25.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime26 = startTime26.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime27 = startTime27.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime28 = startTime28.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime29 = startTime29.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime30 = startTime30.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime31 = startTime31.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime32 = startTime32.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime33 = startTime33.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime34 = startTime34.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime35 = startTime35.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime36 = startTime36.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime37 = startTime37.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime38 = startTime38.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime39 = startTime39.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime40 = startTime40.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime41 = startTime41.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime42 = startTime42.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime43 = startTime43.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime44 = startTime44.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime45 = startTime45.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime46 = startTime46.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime47 = startTime47.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime48 = startTime48.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime49 = startTime49.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime50 = startTime50.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime51 = startTime51.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime52 = startTime52.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime53 = startTime53.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));
    final DateTime endTime54 = startTime54.add(const Duration(days: 0, hours: 23, minutes: 59, seconds: 59));










    meetings.add(Meeting('Light Fasting', startTime, endTime, Colors.amber, false));
    meetings.add(Meeting('First Of Mandaic  Ab', startTime2, endTime2, Colors.green, false));
    meetings.add(Meeting('Poet Lamia Abbas Emara Al-Mandawi \n Born: 1929, Baghdad \n Died: 01/18/2021, California, USA\n Milwasha: Mamani Beth-Mahnash', startTime3, endTime3, Colors.black, false));
    meetings.add(Meeting('First Of Mandaic Month: Aylul', startTime4, endTime4, Colors.green, false));
    meetings.add(Meeting('Resh-ima Abdullah Kanzbara Najim\nKanzabara Zahron Resh-Ima Abdullah\nBorn: 07/01/1927\nDied: 03/04/2010\n Milwasha: Ram Yehana Bet-Simet', startTime5, endTime5, Colors.black, false));
    meetings.add(Meeting('Heavy Fasting', startTime6, endTime6, Colors.red, false));
    meetings.add(Meeting('Heavy Fasting', startTime7, endTime7, Colors.red, false));
    meetings.add(Meeting('Heavy Fasting', startTime8, endTime8, Colors.red, false));
    meetings.add(Meeting('Heavy Fasting', startTime10, endTime10, Colors.red, false));
    meetings.add(Meeting('Benja (pronaya) Feast: Day 1', startTime11, endTime11, Colors.blue, false));
    meetings.add(Meeting('Benja (pronaya) Feast: Day 2', startTime12, endTime12, Colors.blue, false));
    meetings.add(Meeting('Benja (pronaya) Feast: Day 3', startTime13, endTime13, Colors.blue, false));
    meetings.add(Meeting('Benja (pronaya) Feast: Day 4', startTime14, endTime14, Colors.blue, false));
    meetings.add(Meeting('Benja (pronaya) Feast: Day 5', startTime15, endTime15, Colors.blue, false));
    meetings.add(Meeting('First Of Mandaic Month: Tishrin', startTime16, endTime16, Colors.green, false));
    meetings.add(Meeting('Light Fasting', startTime16, endTime16, Colors.amber, false));
    meetings.add(Meeting('First Of Mandaic Month: Mashrowan', startTime17, endTime17, Colors.green, false));
    meetings.add(Meeting('Dehba ad Demana Feast', startTime18, endTime18, Colors.blue, false));
    meetings.add(Meeting('First Of Mandaic Month: Kanoon', startTime18, endTime18, Colors.green, false));
    meetings.add(Meeting('Heavy Fasting', startTime19, endTime19, Colors.red, false));
    meetings.add(Meeting('First Of Manaic Month: Tabeeth', startTime20, endTime20, Colors.green, false));
    meetings.add(Meeting('The Head Imma', startTime21, endTime21, Colors.black, false));
    meetings.add(Meeting('The Scholar Abdul', startTime22, endTime22, Colors.black, false));
    meetings.add(Meeting('Light Fasting', startTime23, endTime23, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime24, endTime24, Colors.amber, false));
    meetings.add(Meeting('Kenshi we Zehli Feast: New Years Eve & First Day Karsa', startTime25, endTime25, Colors.blue, false));
    meetings.add(Meeting('The Great Feast (Dehba ad Raba): New Years Day & Second Karsa Day', startTime26, endTime26, Colors.blue, false));
    meetings.add(Meeting('First Of Mandaic Month: Shabat', startTime26, endTime26, Colors.green, false));
    meetings.add(Meeting('Light Fasting', startTime26, endTime26, Colors.amber, false));
    meetings.add(Meeting('The Great Feast Continuation: End Of Karsa', startTime27, endTime27, Colors.blue, false));
    meetings.add(Meeting('Light Fasting', startTime27, endTime27, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime28, endTime28, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime29, endTime29, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime30, endTime30, Colors.amber, false));
    meetings.add(Meeting('Remembrance Of Shoshian Feast - Day 1', startTime31, endTime31, Colors.blue, false));
    meetings.add(Meeting('Heavy Fasting', startTime31, endTime31, Colors.red, false));
    meetings.add(Meeting('Remembrance Of Shoshian Feast - Day 2', startTime32, endTime32, Colors.blue, false));
    meetings.add(Meeting('Heavy Fasting', startTime32, endTime32, Colors.red, false));
    meetings.add(Meeting('Light Fasting', startTime33, endTime33, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime34, endTime34, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime35, endTime35, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime36, endTime36, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime37, endTime37, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime38, endTime38, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime39, endTime39, Colors.amber, false));
    meetings.add(Meeting('Day Of Purification', startTime40, endTime40, Colors.blue, false));
    meetings.add(Meeting('Light Fasting', startTime41, endTime41, Colors.amber, false));
    meetings.add(Meeting('First Of Mandian Month: Adaar', startTime42, endTime42, Colors.green, false));
    meetings.add(Meeting('Light Fasting', startTime43, endTime43, Colors.amber, false));
    meetings.add(Meeting('First Of Mandian Month: Nisan', startTime44, endTime44, Colors.green, false));
    meetings.add(Meeting('The Def Al-Fil Feast', startTime45, endTime45, Colors.blue, false));
    meetings.add(Meeting('First Of Mandaic Month: Ayar', startTime45, endTime45, Colors.green, false));
    meetings.add(Meeting('Light Fasting', startTime45, endTime45, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime46, endTime46, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime47, endTime47, Colors.amber, false));
    meetings.add(Meeting('Light Fasting', startTime48, endTime48, Colors.amber, false));
    meetings.add(Meeting('The Smallest Feast (Dehba Ad Hanena)', startTime49, endTime49, Colors.blue, false));
    meetings.add(Meeting('First Of Mandaic Month: Sewan', startTime50, endTime50, Colors.green, false));
    meetings.add(Meeting('The Poet', startTime51, endTime51, Colors.black, false));
    meetings.add(Meeting('The Recompense Day (Abu Al-Hires)', startTime52, endTime52, Colors.blue, false));
    meetings.add(Meeting('First Day Of Mandaic Month: Tammuz', startTime52, endTime52, Colors.green, false));
    meetings.add(Meeting('Light Day Fasting', startTime53, endTime53, Colors.amber, false));
    meetings.add(Meeting('Light Day Fasting', startTime54, endTime54, Colors.amber, false));
    meetings.add(Meeting('Al-Ganzura Sheikh Jabbar Tawoos', startTime54, endTime54, Colors.black, false));

    return meetings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Mandaean Calendar',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0, // Remove app bar shadow
      ),
      body: Column(
        children: [
          // Calendar view buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCalendarButton("Month", CalendarView.month),
                _buildCalendarButton("Week", CalendarView.week),
                _buildCalendarButton("Day", CalendarView.day),
              ],
            ),
          ),
          // Calendar widget
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SfCalendar(
                view: _calendarView,
                initialSelectedDate: DateTime.now(),
                controller: _calendarController,
                cellBorderColor: Colors.transparent,
                dataSource: MeetingDataSource(_getDataSource()),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  showAgenda: true,
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(color: Colors.black),
                  ),
                ),
                todayHighlightColor: Colors.black,
                showNavigationArrow: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarButton(String text, CalendarView view) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _calendarView = view;
          _calendarController.view = _calendarView;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: _calendarView == view ? Colors.amber : Colors.black, backgroundColor: _calendarView == view ? Colors.white : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black),
        ),
      ),
      child: Text(text),
    );
  }
}