import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading assets
import 'package:sensors_plus/sensors_plus.dart';
import 'package:the_mandean_app/screens/books_tab/ginza_screen.dart';

import '../books_tab/bookOfJohnScreen.dart';
import '../books_tab/ginzaArabic.dart';
import 'brakha_lyric_screen.dart';
import 'day_of_week_prayer_lyric_screen.dart';
import 'rushama_lyric_screen.dart';

class PrayerTab extends StatefulWidget {
  const PrayerTab({super.key});

  @override
  State<PrayerTab> createState() => _PrayerTabState();
}

class _PrayerTabState extends State<PrayerTab> with SingleTickerProviderStateMixin {
  double _currentHeading = 0;
  late TabController _tabController;

  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  late PageController _pageController;
  int _currentPage = 0;

  // Cache the prayer data
  List<Map<String, dynamic>> _prayerLyrics = [];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();


    // Initialize magnetometer for other purposes
    double lastHeading = 0;
    const double updateThreshold = 1.0;

    _magnetometerSubscription =
        magnetometerEventStream().listen((MagnetometerEvent event) {
          final double heading = atan2(event.y, event.x) * (180 / pi);
          if ((heading - lastHeading).abs() > updateThreshold) {
            lastHeading = heading;
            _currentHeading = heading; // Update without triggering `setState`
          }
        });

    // Load the prayer content once
    _loadPrayerLyrics();
    // Switch tabs based on the time of the day
    _setTabBasedOnTime();
  }

  @override
  void dispose() {
    _magnetometerSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _loadPrayerLyrics() async {
    // Load lyrics only once and store them
    final String response = await rootBundle.loadString(
        'assets/prayers/rushama.json');
    setState(() {
      _prayerLyrics = List<Map<String, dynamic>>.from(json.decode(response));
    });
  }

  void _setTabBasedOnTime() {
    final DateTime now = DateTime.now();

    // time ranges for morning, noon, and evening
    final int morningStart = 5; // 5:00 AM
    final int noonStart = 12; // 12:00 PM
    final int eveningStart = 18; // 6:00 PM (6 PM)

    // Set the tab based on the current hour
    if (now.hour >= morningStart && now.hour < noonStart) {
      _tabController.index = 0; // Morning
    } else if (now.hour >= noonStart && now.hour < eveningStart) {
      _tabController.index = 1; // Noon
    } else {
      _tabController.index = 2; // Evening
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int currentDayIndex = now.weekday % 7; // Monday = 1, Sunday = 7
    final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final String formattedDate = '${now.day} ${_monthName(now.month)} ${now
        .year}';

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 50.0, left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "THIS WEEK'S THEME",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 0),
                          const Text(
                            "A Life of Peace",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 19,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // Distribute evenly
                    children: List.generate(days.length, (index) {
                      return Expanded( // Ensure equal spacing
                        child: _buildDayCircle(
                          days[index],
                          isSelected: index == currentDayIndex,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  _buildPassageCard(),
                  const SizedBox(height: 16),
                  _buildPrayerMechanic(),
                ],
              ),
            ),
          ),
          // Hamburger Menu on the left
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () {
                // Open the menu (you can implement your menu opening logic here)
                print("Hamburger menu tapped");
              },
              child: const Icon(
                Icons.menu,
                size: 30,
                color: Colors.black,
              ),
            ),
          ),
          // Search Icon on the right
          Positioned(
            top: 50,
            right: 16,
            child: GestureDetector(
              onTap: () {
                // Open search (implement search logic here)
                print("Search icon tapped");
              },
              child: const Icon(
                Icons.search,
                size: 30,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCircle(String day, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey,
            width: isSelected ? 2.5 : 2.0,
          ),
        ),
        child: Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: day[0], // First letter of the day
                  style: TextStyle(
                    fontSize: 18, // Larger font size for the first letter
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.amber : Colors.grey,
                  ),
                ),
                TextSpan(
                  text: day.length > 1 ? day.substring(1) : '',
                  // Remaining letters
                  style: TextStyle(
                    fontSize: 14, // Smaller font size for the rest
                    color: isSelected ? Colors.amber : Colors.grey,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildPassageCard() {
    return Column(
      children: [
        Container(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 4, // Number of books (change as needed)
            itemBuilder: (context, index) {
              return _buildPassageItem(index);
            },
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        SizedBox(height: 10),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.amber : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPassageItem(int index) {
    // You can replace these with dynamic values (e.g., from a list or model)
    List<String> bookTitles = [
      "Ginza Rabba",
      "كتاب الكنزا العربية",
      "Book Of John",
      "Book 4"
    ];

    List<String> hymns = [
      "Official Holy Book For Mandaeans",
      "الكتاب المقدس الرئيسي للمندائيين",
      "Charles Harberl & James McGrath",
      "Hymns of Gratitude"
    ];

    List<String> passageTexts = [
      "Blessed Be Those Who Call Your Name Manda 'd Hayyi",
      "هو الأزلي القديم ، الغريب عن ألوان النور ، الغني عن أكوان النور",
      "© 2020 Walter de Gruyter GmbH and may be freely shared for non-commercial purposes, with friendly permission by Walter de Gruyter GmbH.",
      "He Who Guides Us with His Light"
    ];

    // Corresponding unique routes for each passage
    List<Widget> listenRoutes = [
      //ListenPage1(), // Replace with the actual pages you want
      //ListenPage2(),
      //ListenPage3(),
      //ListenPage4(),
    ];

    List<Widget> readRoutes = [
      GinzaScreen(),
      //ReadPage2(),
      GinzaArabicScreen(),
      BookOfJohnScreen(),
    ];

    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF423E34), // Darker shade
              const Color(0xFF927560), // Lighter complementary shade
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.menu_book, // Book icon
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bookTitles[index],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                hymns[index],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                passageTexts[index],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors
                      .white70, // Slightly lighter white for secondary text
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the Listen page for the current passage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              context) => listenRoutes[index]),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFED58A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 55),
                      ),
                      child: const Text(
                        "LISTEN",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the Read page for the current passage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              context) => readRoutes[index]),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFED58A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 55),
                      ),
                      child: const Text(
                        "READ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPrayerMechanic() {
    return Expanded(
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.amber,
              tabs: const [
                Tab(text: "Morning"),
                Tab(text: "Noon"),
                Tab(text: "Evening"),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  _buildScrollablePrayerTabContent(),
                  _buildScrollablePrayerTabContent(),
                  _buildScrollablePrayerTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollablePrayerTabContent() {
    if (_prayerLyrics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final DateTime now = DateTime.now();
    final List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final String currentDay = daysOfWeek[now.weekday %
        7]; // Get current day name

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BrakhaLyricScreen(),
                ));
              },
              child: _buildPrayerContent(
                  "Brakha", "assets/images/prayer_picture_2.png"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(_createRoute(_prayerLyrics));
              },
              child: _buildPrayerContent(
                  "Rishama", "assets/images/prayer_picture_3.png"),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the DayOfWeekPrayerLyricScreen for the current day
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      DayOfWeekPrayerLyricScreen(currentDay: currentDay),
                ));
              },
              child: _buildPrayerContent(
                  "$currentDay Prayer", "assets/images/prayer_picture_4.png"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerContent(String title, String imageUrl) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 6,
                    color: Color.fromARGB(125, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute(List<Map<String, dynamic>> lyrics) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LyricsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from the right
        const end = Offset.zero; // End at the center
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}