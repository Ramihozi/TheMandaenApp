import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading assets
import 'package:sensors_plus/sensors_plus.dart';

import 'rushama_lyric_screen.dart';

class PrayerTab extends StatefulWidget {
  const PrayerTab({super.key});

  @override
  State<PrayerTab> createState() => _PrayerTabState();
}
class _PrayerTabState extends State<PrayerTab> {
  double _currentHeading = 0;
  @override
  void initState() {
    super.initState();

    // Throttle magnetometer updates
    double lastHeading = 0;
    const double updateThreshold = 1.0; // Only update if heading changes by 1 degree or more
    magnetometerEventStream().listen((MagnetometerEvent event) {
      final double heading = atan2(event.y, event.x) * (180 / pi);

      // Check if the heading change exceeds the threshold
      if ((heading - lastHeading).abs() > updateThreshold) {
        lastHeading = heading;
        if (mounted) {
          setState(() {
            _currentHeading = heading;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int currentDayIndex = now.weekday % 7; // Monday = 1, Sunday = 7
    final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final String formattedDate = '${now.day} ${_monthName(now.month)} ${now.year}';

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute evenly
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
                  text: day.length > 1 ? day.substring(1) : '', // Remaining letters
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
    return Container(
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
                    Icons.menu_book, // Changed icon to represent a book better
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Niani",
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
              "Hymns Of Praise ",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Blessed Be Those Who Call Your Name Manda 'd Hayyi",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70, // Slightly lighter white for secondary text
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFED58A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 55), // Increased height
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFED58A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 55), // Increased height
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
    );
  }


  Widget _buildPrayerMechanic() {
    return Expanded(
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
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
              child: TabBarView(
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

  Future<List<Map<String, dynamic>>> _loadLyricsFromFile() async {
    final String response = await rootBundle.loadString('assets/prayers/rushama.json');
    return List<Map<String, dynamic>>.from(json.decode(response));
  }
  Widget _buildScrollablePrayerTabContent() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadLyricsFromFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading lyrics'));
        }

        final lyrics = snapshot.data ?? [];
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
        final String currentDay = daysOfWeek[now.weekday % 7]; // Get current day name

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              children: [
                _buildPrayerContent("Brakha", "assets/images/rushama.avif"),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(_createRoute(lyrics));
                  },
                  child: _buildPrayerContent("Rishama", "assets/images/rushama.avif"),
                ),
                _buildPrayerContent("$currentDay Prayer", "assets/images/rushama.avif"),
              ],
            ),
          ),
        );
      },
    );
  }Widget _buildPrayerContent(String title, String imageUrl) {
    return RepaintBoundary(
      child: Container(
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
      ),
    );
  }
  Route _createRoute(List<Map<String, dynamic>> lyrics) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LyricsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from the right
        const end = Offset.zero;        // End at the center
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}