import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_mandean_app/calendar/meeting.dart';
import 'package:the_mandean_app/calendar/meeting_data_source.dart';
import 'package:get/get.dart';
import 'profile_tab/community_profile_controller.dart'; // For RxBool and state management

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late CalendarView _calendarView;
  late CalendarController _calendarController;
  final ProfileController _profileController = Get.find(); // Access ProfileController

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

    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime,
      endTime,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
    'First Of Mandaic Ab',
    'أول شهر مندائي آب',
    startTime2,
    endTime2,
    Colors.green,
    false,
    ));
    meetings.add(Meeting(
      'Poet Lamia Abbas Emara Al-Mandawi \n Born: 1929, Baghdad \n Died: 01/18/2021, California, USA\n Milwasha: Mamani Beth-Mahnash',
      'الشاعرة لمياء عباس عمارة المندوي \n ولدت: ١٩٢٩، بغداد \n توفيت: 01/18/2021، كاليفورنيا، الولايات المتحدة الأمريكية \n الميلواشة: ماماني يث-مهنش',
      startTime3,
      endTime3,
      Colors.black,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandaic Month: Aylul',
      'أول شهر مندائي: أيلول',
      startTime4,
      endTime4,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'Resh-ima Abdullah Kanzbara Najim\nKanzabara Zahron Resh-Ima Abdullah\nBorn: 07/01/1927\nDied: 03/04/2010\n Milwasha: Ram Yehana Ber-Simet',
      'ريش امة عبد الله كنزبرا نجم\nكنزبرا زهرون ريش-إمة عبد الله\nولد: 07/01/1927\nتوفي: 03/04/2010\n الملواشة: رام يهانة بر-سيمت',
      startTime5,
      endTime5,
      Colors.black,
      false,
    ));
    meetings.add(Meeting(
      'Heavy Fasting',
      'صيام ثقيل',
      startTime6,
      endTime6,
      Colors.red,
      false,
    ));
    meetings.add(Meeting(
      'Heavy Fasting',
      'صيام ثقيل',
      startTime7,
      endTime7,
      Colors.red,
      false,
    ));
    meetings.add(Meeting(
      'Heavy Fasting',
      'صيام ثقيل',
      startTime8,
      endTime8,
      Colors.red,
      false,
    ));
    meetings.add(Meeting(
      'Heavy Fasting',
      'صيام ثقيل',
      startTime10,
      endTime10,
      Colors.red,
      false,
    ));
    meetings.add(Meeting(
      'Benja (pronaya) Feast: Day 1',
      'عيد البنجة (برونايا): اليوم الأول',
      startTime11,
      endTime11,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'Benja (pronaya) Feast: Day 2',
      'عيد البنجة (برونايا): اليوم الثاني',
      startTime12,
      endTime12,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'Benja (pronaya) Feast: Day 3',
      'عيد البنجة (برونايا): اليوم الثالث',
      startTime13,
      endTime13,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'Benja (pronaya) Feast: Day 4',
      'عيد البنجة (برونايا): اليوم الرابع',
      startTime14,
      endTime14,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'Benja (pronaya) Feast: Day 5',
      'عيد البنجة (برونايا): اليوم الخامس',
      startTime15,
      endTime15,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandaic Month: Tishrin',
      'أول شهر مندائي: تشرين',
      startTime16,
      endTime16,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime16,
      endTime16,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandaic Month: Mashrowan',
      'أول شهر مندائي: مشروان',
      startTime17,
      endTime17,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'Dehba ad Demana Feast',
      'عيد دِهبا اد يمانا',
      startTime18,
      endTime18,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandaic Month: Kanoon',
      'أول شهر مندائي: كانون',
      startTime18,
      endTime18,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'Heavy Fasting',
      'صيام ثقيل',
      startTime19,
      endTime19,
      Colors.red,
      false,
    ));
    meetings.add(Meeting(
      'First Of Manaic Month: Tabeeth',
      'أول شهر مندائي: طابيت',
      startTime20,
      endTime20,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'The Head Imma',
      'رئيس إما',
      startTime21,
      endTime21,
      Colors.black,
      false,
    ));
    meetings.add(Meeting(
      'The Scholar Abdul',
      'العالم عبد الله',
      startTime22,
      endTime22,
      Colors.black,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime23,
      endTime23,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime24,
      endTime24,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Kenshi we Zehli Feast: New Years Eve & First Day Karsa',
      'عيد كلشي وزهلي: ليلة رأس السنة واليوم الأول للكراص',
      startTime25,
      endTime25,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'The Great Feast (Dehba Raba): New Years Day & Second Karsa Day',
      'العيد الكبير (عيد دِهبا ِرَبا): ليلة رأس السنة واليوم الثاني للكراص',
      startTime26,
      endTime26,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandaic Month: Shbat',
      'أول شهر مندائي: شباط',
      startTime26,
      endTime26,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime26,
      endTime26,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'The Great Feast Continuation: End Of Karsa',
      'ثالث ايام العيد الكبير: نهاية الكراص',
      startTime27,
      endTime27,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime27,
      endTime27,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime28,
      endTime28,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime29,
      endTime29,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime30,
      endTime30,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Remembrance Of Shoshian Feast - Day 1',
      'عيد شوشيان - اليوم الأول',
      startTime31,
      endTime31,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'Heavy Fasting',
      'صيام ثقيل',
      startTime31,
      endTime31,
      Colors.red,
      false,
    ));
    meetings.add(Meeting(
      'Remembrance Of Shoshian Feast - Day 2',
      'عيد شوشيان - اليوم الثاني',
      startTime32,
      endTime32,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'Heavy Fasting',
      'صيام ثقيل',
      startTime32,
      endTime32,
      Colors.red,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime33,
      endTime33,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime34,
      endTime34,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime35,
      endTime35,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime36,
      endTime36,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime37,
      endTime37,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime38,
      endTime38,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime39,
      endTime39,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Day Of Purification',
      'يوم نظيف',
      startTime40,
      endTime40,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandian Month: Adaar',
      'أول شهر مندائي: آذار',
      startTime42,
      endTime42,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime43,
      endTime43,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandian Month: Nisan',
      'أول شهر مندائي: نيسان',
      startTime44,
      endTime44,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'The Def Al-Fil Feast',
      'عيد دك ابو الفل',
      startTime45,
      endTime45,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandaic Month: Ayar',
      'أول شهر مندائي: أيار',
      startTime45,
      endTime45,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime45,
      endTime45,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime46,
      endTime46,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime47,
      endTime47,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime48,
      endTime48,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'The Smallest Feast (Dehba Ad Hanena)',
      'أصغر عيد (عيد دِهوا اد هنينا)',
      startTime49,
      endTime49,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'First Of Mandaic Month: Sewan',
      'أول شهر مندائي: سيوان',
      startTime50,
      endTime50,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'The Poet',
      'الشاعر',
      startTime51,
      endTime51,
      Colors.black,
      false,
    ));
    meetings.add(Meeting(
      'The Recompense Day (Abu Al-Hires)',
      'ذكرى الطوفان (ابو الهريس)',
      startTime52,
      endTime52,
      Colors.blue,
      false,
    ));
    meetings.add(Meeting(
      'First Day Of Mandaic Month: Tammuz',
      'أول يوم من شهر مندائي: تموز',
      startTime52,
      endTime52,
      Colors.green,
      false,
    ));
    meetings.add(Meeting(
      'Light Fasting',
      'صيام خفيف',
      startTime53,
      endTime53,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Light Day Fasting',
      'صيام خفيف',
      startTime54,
      endTime54,
      Colors.amber,
      false,
    ));
    meetings.add(Meeting(
      'Al-Kanzibra Sheikh Jabbar Tawoos \n Born: 1923 \n Died: December twenty-seven, two thousand and seventeen \n Milwasha: Mhatam Yuhana',
      'الكنزبرا الشيخ جبار طاووس \n مواليد: 1923 الوفاة: سبعة وعشرون ديسمبر ألفين وسبعة عشر الملواشة: مهتم بر يهانة',
      startTime54,
      endTime54,
      Colors.black,
      false,
    ));



    return meetings;
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEnglish = _profileController.isEnglish.value;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            isEnglish ? 'Mandaean Calendar' : 'التقويم المندائي',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Calendar view buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCalendarButton(isEnglish ? "Month" : "شهر", CalendarView.month),
                  _buildCalendarButton(isEnglish ? "Week" : "أسبوع", CalendarView.week),
                  _buildCalendarButton(isEnglish ? "Day" : "يوم", CalendarView.day),
                ],
              ),
            ),
            // Calendar widget
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: SfCalendar(
                  view: _calendarView,
                  initialSelectedDate: DateTime.now(),
                  controller: _calendarController,
                  cellBorderColor: Colors.transparent,
                  dataSource: MeetingDataSource(_getDataSource(), isEnglish),
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.amber, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                    showAgenda: true,
                    agendaItemHeight: 60, // Adjust this for bigger event cards
                    monthCellStyle: MonthCellStyle(
                      backgroundColor: Colors.white,
                      textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    agendaStyle: AgendaStyle(
                      appointmentTextStyle: TextStyle(
                        fontSize: 16, // Increase the font size for event titles
                        color: Colors.black,
                      ),
                    ),
                  ),
                  todayHighlightColor: Colors.amber,
                  showNavigationArrow: true,
                ),
              ),
            ),
          ],
        ),
      );
    });
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
        foregroundColor: _calendarView == view ? Colors.white : Colors.black, backgroundColor: _calendarView == view ? Colors.amber : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}