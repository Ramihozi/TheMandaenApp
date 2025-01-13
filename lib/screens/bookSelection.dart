import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/bookOfJohnScreen.dart';
import 'package:the_mandean_app/screens/ginza_screen.dart';
import 'community_profile_controller.dart';
import 'ginzaArabic.dart';

class BooksSelectionScreen extends StatelessWidget {
  const BooksSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final isEnglish = Get.find<ProfileController>().isEnglish.value;
          return Text(isEnglish ? 'Mandaean Books' : 'الكتب المندائية'); // Change title based on language
        }),
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildBookCard(
            context: context,
            title: 'Ginza Rabba (English)',
            imagePath: 'assets/images/bookVector.png',
            description: 'Official Holy Book For Mandaeans',
            pageCount: 345,
            onTap: () {
              _showComingSoonDialog(context); // Show dialog when clicked
            },
          ),
          const SizedBox(height: 16),
          _buildBookCard(
            context: context,
            title: 'كتاب الكنزا العربية',
            imagePath: 'assets/images/bookVector.png',
            description: 'الكتاب المقدس الرئيسي للمندائيين',
            pageCount: 345,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GinzaArabicScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildBookCard(
            context: context,
            title: 'Mandaean Book Of John',
            imagePath: 'assets/images/bookVector.png',
            description: 'Charles Haberl and James McGrath',
            pageCount: 250,
            onTap: () {
              Get.to(() => BookOfJohnScreen(), transition: Transition.rightToLeft);
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: const Text(
            'Sorry, The Proper Corrected English Ginza Is Coming Very Soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // Golden color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required String description,
    required int pageCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
          ),
          Card(
            color: Colors.grey[100],
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(left: 20, right: 0),
            child: Container(
              height: 110,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.grey[100]!.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 120),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pageCount pages',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: -8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.amber.withOpacity(0.9),
                  BlendMode.srcATop,
                ),
                child: Image.asset(
                  imagePath,
                  height: 130,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
