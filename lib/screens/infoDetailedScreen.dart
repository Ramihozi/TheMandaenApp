import 'package:flutter/material.dart';

class InfoDetailScreen extends StatelessWidget {
  final String title;
  final List<String> paragraphs;
  final String image;
  final double imageWidth;
  final double imageHeight;

  const InfoDetailScreen({
    super.key,
    required this.title,
    required this.paragraphs,
    required this.image,
    this.imageWidth = 400, // Default width
    this.imageHeight = 300, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered image with fixed dimensions
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Title section
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Paragraphs
            for (var paragraph in paragraphs) ...[
              Text(
                paragraph,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
