import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'infoDetailedScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  Map<String, String>? dailyVerse;
  List<Map<String, dynamic>> informationalItems = [
    {
      'title': 'History',
      'paragraphs': [
        'Learn about the history of our religion in detail.',
        'Our history spans centuries, full of rich traditions and significant events.',
        'Here we discuss important milestones and figures in our religion.',
      ],
      'image': 'assets/images/darfesh1.jpeg',
    },
    {
      'title': 'Beliefs',
      'paragraphs': [
        'Understand our core beliefs and values.',
        'Our beliefs are the foundation of our faith.',
        'Explore the teachings that guide our daily lives and spiritual journey.',
      ],
      'image': 'assets/images/hayyi.jpeg',
    },
    {
      'title': 'Practices',
      'paragraphs': [
        'Discover our religious practices and rituals.',
        'These include daily prayers, ceremonies, and moral codes.',
        'These practices help us stay connected to our faith.',
      ],
      'image': 'assets/images/masbutta.jpeg',
    },
    {
      'title': 'Festivals',
      'paragraphs': [
        'Explore our religious festivals and celebrations.',
        'Each festival holds unique significance.',
        'Festivals are celebrated with great enthusiasm.',
      ],
      'image': 'assets/images/festival.jpeg',
    },
    {
      'title': 'Texts',
      'paragraphs': [
        'Read our sacred texts and scriptures.',
        'These texts contain the teachings and philosophies of our religion.',
        'They are revered and studied extensively.',
      ],
      'image': 'assets/images/texts.jpeg',
    },
  ];

  List<Map<String, String>> resourceItems = [
    {
      'title': 'Wikipedia',
      'link': 'https://en.wikipedia.org/wiki/Mandaeans',
      'description': 'Official Mandaean Wikipedia',
    },
    {
      'title': 'Podcast',
      'link': 'https://www.youtube.com/@WeTheMandaeans',
      'description': 'Official Podcast For Mandaeans',
    },
    {
      'title': 'Nasorean Instagram',
      'link': 'https://www.instagram.com/nasoraean/',
      'description': 'Informational Instagram For Mandaeans',
    },
    {
      'title': 'I-Am-Mandaean instagram',
      'link': 'https://www.instagram.com/nasoraean/',
      'description': 'Further Information About Mandaeans',
    },
    {
      'title': 'The Mandaean Association',
      'link': 'https://www.facebook.com/SabianMandaeanAssociation',
      'description': 'Official Mandaean Facebook ',
    }

    // Add more resources as needed
  ];

  @override
  void initState() {
    super.initState();
    loadRandomVerse();
  }

  Future<void> loadRandomVerse() async {
    String data = await rootBundle.loadString('assets/ginzas/al-saadiENG.json');
    List verses = json.decode(data);
    final random = Random();
    int randomIndex = random.nextInt(verses.length);

    setState(() {
      dailyVerse = {
        'book': verses[randomIndex]['book'],
        'chapter': verses[randomIndex]['chapter'],
        'verse': verses[randomIndex]['verse'],
        'text': verses[randomIndex]['text'],
      };
    });
  }

  void copyToClipboard() {
    if (dailyVerse != null) {
      final quote = '${dailyVerse!['text']} - ${dailyVerse!['book']} ${dailyVerse!['chapter']}:${dailyVerse!['verse']}';
      Clipboard.setData(ClipboardData(text: quote));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GinzApp'),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: loadRandomVerse,
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Verse',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (dailyVerse != null)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dailyVerse!['text']!,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '- ${dailyVerse!['book']} ${dailyVerse!['chapter']}:${dailyVerse!['verse']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: copyToClipboard,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Quote'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              const Text(
                'Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 175,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: informationalItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 500),
                            pageBuilder: (context, animation, secondaryAnimation) => InfoDetailScreen(
                              title: informationalItems[index]['title']!,
                              paragraphs: List<String>.from(informationalItems[index]['paragraphs']),
                              image: informationalItems[index]['image']!,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SizedBox(
                          width: 200,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.asset(
                                  informationalItems[index]['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black.withOpacity(0.3),
                                  colorBlendMode: BlendMode.darken,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      informationalItems[index]['title']!,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      (informationalItems[index]['paragraphs'] as List<String>).first,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Resources',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: resourceItems.map((resource) {
                  return ListTile(
                    title: Text(
                      resource['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      resource['description']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () {
                        // Handle tapping on the link
                        // Example: launchURL(resource['link']!);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}