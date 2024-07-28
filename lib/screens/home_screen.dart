import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
        'Mandaeaism is the oldest surviving religion that can be traced back to the pre-Christian era. A large number of the Mandaeans lived in the Jordan valley, Syria and its surrounding areas. Other communities of the Mandaeans had also long settled throughout the Mesopotamian and Persian lands. '
            'They are considered as the indigenous Mesopotamian people. After the death of their last great Teacher, John the Baptist, '
            'the communities in Jordan and Palestine came under persecution and eventually migrated to join other Mandaeans. '
            'They settled in Iraq and Iran, especially around the upper middle and lower Euphrates, the Tigris and the Kāron Rivers in Khuzestan Province. Today, the Mandaeans number more than 80,000 strong believers, but no longer concentrate in Iraq and Iran.',

        'The twentieth century has brought about a dramatic change in the geographical location of Mandaean communities. The majority of Mandaeans now live in diaspora due to the severe persecution and regional wars in Iraq and Iran. The most recent disruption to Mandaean life in the Middle East was due to the United States’ invasion of Iraq.'
            ' The Mandaeans can be found in large numbers now living in Europe, Australia, the United States, Canada, New Zealand, as well as Syria, Jordan, Turkey and Indonesia.'

        '\n\nThere are probably less than 5,000 Mandaeans living in Iraq and roughly less than 1,700 remaining in Iran. The Mandaeans have been traditionally involved in various artisan trades. They are well-educated and highly skilled professionals, usually working as gold and silversmiths or as jewelers.'
      ],
      'image': 'assets/images/darfesh1.jpeg',
    },
    {
      'title': 'Beliefs',
      'paragraphs': [
        'Life: Recognition of the existence of one God, whom Nasurai call "Hayyi" which in Aramaic means "the Living" or life itself. The Great Life (or Supreme Deity) is a personification of the creative and sustaining force of the universe, and is spoken of always in the impersonal plural, it remains mystery and abstraction. '
            'The symbol of the Great Life is flowing living water or yardna. Because of this, flowing water holds a central place in all Nasurai rituals, hence the necessity of living near rivers.',
        'Light: The second vivifying power is light, which is represented by a personification of light, Melka d Nhura (the King of Light) and the light spirits, who bestow health, strength, virtue and justice. In the ethical system of the Mandaeans, cleanliness, health of body and ritual obedience must be accompanied by purity of mind, health of conscience and obedience to moral laws. '
            'A phrase in the Manual of Discipline reads: that they may behold the Light of Life.',
        'Immortality: The third important rite of the religion is the belief in the immortality of the soul, and its close relationship with the souls of its ancestors, immediate and divine. The fate of the soul is a chief concern, while the body is treated with disdain. '
            'Belief in the existence of the next life, in which there will be reward and punishment. The sinner will be punished in al-Matarathi and then enter Paradise. There is no eternal punishment because God is merciful and forgiving.',
      ],
      'image': 'assets/images/hayyi.jpeg',
    },
    {
      'title': 'Practices',
      'paragraphs': [
        'PRAYER: Mandaeans must face the North (Pole) Star during prayers. This mis-conception of star worship comes from the fact that although the Mandaean are monotheists, they pay adoration to the angels and the good and free spirits which they believe reside in the stars and from which they govern the world under the Supreme Deity. Kneeling and prostration during prayer is unknown, neither is the covering of the face with the hands at any time.'
            ' The head is held erect, and the hands are not used. Priests are required to pray a different set prayer each day of the week. Prayer hours are dawn, noon and dusk.',
        'NO CIRCUMCISION: One of their inviolable beliefs was the integrity of the physical body. No part of it should be cut off, for just as God created the person sound and complete so should this trust be returned to him. Circumcision is included in this prohibition.',
        'RESPECT FOR RIVERS: Respect for and sanctification of rivers is such that Mandaeans always try to live near their banks. A major sin as mentioned in the Holy Books is that a person should urinate in a river. However, it is recommended to throw left-over food in water especially the food remaining from ceremonies remembering a deceased person which will be eaten by the river fish.'
            ' This is because the river or Yardna represents Life and Light from which everything was formed and so will return to it. - It involves communion with the Light World and the long departed Souls.',
        'MASBUTA BAPTISM: The third ablution, or full baptism, encompasses all aspects of baptism and must be performed by a priest or priestess. This ablution is known as masbuta (maswetta) includes the sacraments of oil, bread (known as pihtha) and water (from the river only, known as mambuha), the kushta (the hand grasp and kiss) and the final blessing by laying the right hand of the priest on the head of the baptized person.'
            ' The masbuta should take place on Sunday, after major defilement\'s (i.e.. childbirth, marriage, illness and even after a journey) and especially for those who have lied or who have had violent quarrels, indeed after any action which is ashamed of. Major sins such as theft, murder, and adultery require more than one baptism.',
        'DIET & PURITY: Food is also ritually cleansed, such as fruits and vegetables before consumption. Other items like the rasta (robes) and kitchen utensils such as pots and pans undergo frequent ritual purifications. Salt is the only exception. Ganzivri (Bishops) and priests must only eat of the food they prepare themselves and their bread may not be baked with that of lay persons. For Ganzivri (Bishops) wine, coffee and tobacco are forbidden to them and they must avoid eating hot or cooked food. '
            'All their fruits and vegetables must be eaten raw. Water is the only beverage of a priest and this must be taken directly from the river or spring. The Mandaeans also use other terms to differentiate amongst themselves on basis of ritual cleanliness, Suwadi is used for laymen, Hallali is applied to ritually pure men, who of their own will follow a high religious standard, and of course Nasurai used for priests. Only that grows from a seed is lawful for food (hence a mushroom is forbidden).'
            ' In practice little meat is eaten, and the attitude towards slaughter is always apologetic, perhaps because all original Nasurai were vegetarians and meat eating only crept in after a departure from their original faith. All killing and blood letting is supposedly sinful and it is forbidden to kill female beasts. Flies, scorpions and all harmful stinging things may be slain without sin. Under Mandaean customs every mother must suckle her own child, it is forbidden to act as a foster mother for hire. The child\'s education and upbringing is the duty of the father, until the child reaches the age of 15 (or 20 according to others, which was the age of adulthood in the Dead Sea Scrolls and Pythagorean tradition).'
      ],
      'image': 'assets/images/masbutta.jpeg',
    },
    {
      'title': 'Festivals',
      'paragraphs': [
        'Parwanaya (Dehwa Rabba) \nWhen: Celebrated in late winter, typically in March. \nDuration: 5 days. \nSignificance: This is the most important festival in the Mandaean calendar, marking the creation of the world and the renewal of life. It is a time for major rituals, including baptisms (masbuta), and for making offerings to spirits and deities. \nActivities: The festival involves daily rituals of purification and baptism in flowing water, prayers, and community feasts. It\'s also a time for the renewal of vows and spiritual cleansing.',
        '\nDehwa Hanina (Little Feast) \nWhen: Typically celebrated in early summer. \nSignificance: This festival commemorates the birth of John the Baptist (Yahya), who is a central figure in Mandaean religion. \nActivities: The celebration includes rituals similar to those of Parwanaya, with a focus on renewal and purification. Community gatherings and feasts are also a key part of the festivities.',
        '\nDehwa d-Šitil (Festival of Sitil) \nWhen: Celebrated in late summer or early autumn. \nSignificance: This festival honors the figure of Šitil (Seth), considered a divine being and a savior figure in Mandaean belief. \nActivities: It involves rituals of purification and baptism, prayers, and communal meals. It is also a time for remembering the dead and making offerings in their honor.',
        '\nPanja (Banja) \nWhen: Celebrated in the summer, usually in July. \nDuration: 5 days. \nSignificance: This festival is dedicated to the spirits and ancestors. It is considered a time when the boundaries between the living and the dead are more permeable. \nActivities: Rituals include baptisms, prayers, and offerings made at the riverbanks. The festival is a time for remembrance and honoring deceased relatives.',
        '\nDehwa d-Edya (New Year Festival) \nWhen: Typically celebrated in early January. \nSignificance: This festival marks the Mandaean New Year and the arrival of light into the world. \nActivities: It involves rituals of purification, special prayers, and feasting. It is a time of joy and renewal, with the community coming together to celebrate the new beginning.',
        '\nQina (Sunday of Remembrance) \nWhen: Celebrated on the first Sunday after Parwanaya. \nSignificance: This day is dedicated to the memory of the deceased and the veneration of ancestors. \nActivities: Rituals include prayers, offerings, and baptisms conducted in honor of the departed souls.'
      ],
      'image': 'assets/images/festival.jpeg',
    },
    {
      'title': 'Texts',
      'paragraphs': [
        'Ginza Rba (The Great Treasure) \nContent: The Ginza Rba is the most important and comprehensive of the Mandaean scriptures. It is divided into two main parts: the Right Ginza and the Left Ginza. The Right Ginza contains cosmological and theological texts, hymns, and prayers, while the Left Ginza deals with eschatological themes, such as the fate of the soul after death. \nThemes: Creation, cosmology, theology, ethics, and eschatology. \nSignificance: This text is considered the primary religious authority and is used in various rituals and ceremonies.',
        'Qolasta \nContent: The Qolasta is a collection of hymns, prayers, and liturgical texts used in Mandaean rituals, particularly those involving baptism (masbuta) and other purification rites. \nThemes: Worship, purification, and spiritual invocation. \nSignificance: The Qolasta is crucial for daily religious practices and is recited during major ceremonies and festivals.',
        'Sidra d-Yahia (The Book of John the Baptist) \nContent: This text contains teachings attributed to John the Baptist (Yahya), a central figure in Mandaean religion, as well as narratives about his life and mission. \nThemes: Ethical teachings, guidance for righteous living, and the role of John the Baptist. \nSignificance: It provides moral and ethical instructions and reinforces the importance of John the Baptist in Mandaean faith.',
        'Diwan Abatur \nContent: The Diwan Abatur is focused on the figure of Abatur, a key angelic being in Mandaean cosmology who judges the souls of the deceased. It describes the journey of the soul after death and the various stages it passes through. \nThemes: Afterlife, judgment, and the soul\'s journey. \nSignificance: It is used in funerary rites and helps Mandaeans understand the afterlife and the importance of living a righteous life.',
        'Haran Gawaita \nContent: This text provides a historical account of the Mandaeans, including their origins and migrations. It includes details about their persecution and the preservation of their religious identity. \nThemes: History, identity, and resilience. \nSignificance: It serves as a historical record and reinforces the community\'s sense of identity and continuity.',
        'Alma Rišaia Rba \nContent: Also known as "The Great First World," this text deals with the creation of the world and the heavenly realms. It describes the structure of the universe and the roles of various divine beings. \nThemes: Creation, cosmology, and divine hierarchy. \nSignificance: It provides a detailed account of Mandaean cosmology and the origins of the universe.',
        'Draša d-Iahia (The Teaching of John) \nContent: Similar to the Sidra d-Yahia, this text contains teachings and discourses attributed to John the Baptist, focusing on spiritual and ethical instructions. \nThemes: Spiritual guidance, ethical conduct, and the teachings of John the Baptist. \nSignificance: It offers practical advice for leading a righteous life and emphasizes the importance of spiritual purity.',
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
      'title': 'I-Am-Mandaean Instagram',
      'link': 'https://www.instagram.com/iam.mandean/',
      'description': 'Further Information About Mandaeans',
    },
    {
      'title': 'The Mandaean Association',
      'link': 'https://www.facebook.com/SabianMandaeanAssociation',
      'description': 'Official Mandaean Facebook',
    }
  ];

  final List<IconData> resourceIcons = [
    Icons.web,
    Icons.podcasts,
    Icons.camera_alt,
    Icons.camera_alt,
    Icons.group
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
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
          iconTheme: const IconThemeData(color: Colors.black),
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
                'Daily Botha (verse)',
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
                height: 225,
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
                          width: 250,
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
                children: List.generate(resourceItems.length, (index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      tileColor: Colors.white,
                      leading: Icon(resourceIcons[index], color: Colors.black),
                      title: Text(
                        resourceItems[index]['title']!,
                        style: const TextStyle(
                          fontSize: 18  ,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        resourceItems[index]['description']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: IconButton(
                              icon: const Icon(Icons.link, color: Colors.amber),
                              onPressed: () {
                                _launchURL(resourceItems[index]['link']!);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
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
