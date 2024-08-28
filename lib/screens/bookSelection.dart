import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/bookOfJohnScreen.dart';
import 'package:the_mandean_app/screens/ginza_screen.dart';

import 'ginzaArabic.dart';
// Import other book screens here

class BooksSelectionScreen extends StatelessWidget {
  const BooksSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandaean Books'),
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
            imagePath: 'assets/images/hayyi.jpeg',
            description: 'The Main Holy Book Of Mandaeans',
            pageCount: 320,
            onTap: () {
              Get.to(() => const GinzaScreen(), transition: Transition.rightToLeft);
            },
          ),
          const SizedBox(height: 16),
          _buildBookCard(
            context: context,
            title: 'Ginza Rabba (Arabic)',
            imagePath: 'assets/images/hayyi.jpeg',
            description: 'The Main Holy Book Of Mandaeans',
            pageCount: 180,
            onTap: () {
              // Navigate to the GinzaArabicScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GinzaArabicScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Inside BooksSelectionScreen
          _buildBookCard(
            context: context,
            title: 'Mandaean Book Of John',
            imagePath: 'assets/images/hayyi.jpeg',
            description: 'Book Of John',
            pageCount: 250,
            onTap: () {
              Get.to(() => BookOfJohnScreen(), transition: Transition.rightToLeft);
            },
          ),
        ],
      ),
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
          Card(
            color: Colors.grey[100],
            elevation: 0,
            margin: const EdgeInsets.only(left: 20, right: 0),
            child: Container(
              height: 110,
              padding: const EdgeInsets.all(8.0),
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
                            fontWeight: FontWeight.w400,
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
            left: 16,
            top: -20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                height: 150,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
