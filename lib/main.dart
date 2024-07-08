import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:the_mandean_app/constants/constants.dart';
import 'package:the_mandean_app/routes/routes.dart';
import 'package:the_mandean_app/screens/ginza_screen.dart';
import 'package:the_mandean_app/screens/splash_screen.dart';
import 'package:the_mandean_app/services/fetch_books.dart';
import 'package:the_mandean_app/services/fetch_verses.dart';
import 'package:provider/provider.dart';
import 'package:the_mandean_app/models/verse.dart';
import 'package:the_mandean_app/services/save_current_index.dart';
import 'package:the_mandean_app/providers/main_provider.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => MainProvider())],
      child: const MainApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mandean App',
        theme: ThemeData(
          primarySwatch: Constants.kSwatchColor,
          primaryColor: Constants.kPrimary,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
        ),
        home: const SplashScreen(),
        getPages: getPages()// Assuming SplashScreen leads to MainApp after some logic
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _loading = true;

  @override
  void initState() {
    Future.delayed(
      const Duration(milliseconds: 100),
          () async {
        MainProvider mainProvider =
        Provider.of<MainProvider>(context, listen: false);
        mainProvider.itemPositionsListener.itemPositions.addListener(
              () {
            int index = mainProvider
                .itemPositionsListener.itemPositions.value.last.index;

            SaveCurrentIndex.execute(
                index: mainProvider
                    .itemPositionsListener.itemPositions.value.first.index);

            Verse currentVerse = mainProvider.verses[index];

            if (mainProvider.currentVerse == null) {
              mainProvider.updateCurrentVerse(verse: mainProvider.verses.first);
            }

            Verse previousVerse = mainProvider.currentVerse == null
                ? mainProvider.verses.first
                : mainProvider.currentVerse!;

            if (currentVerse.book != previousVerse.book) {
              mainProvider.updateCurrentVerse(verse: currentVerse);
            }
          },
        );
        await FetchVerses.execute(mainProvider: mainProvider).then(
              (_) async {
            await FetchBooks.execute(mainProvider: mainProvider)
                .then((_) => setState(() {
              _loading = false;
            }));
          },
        );
      },
    );
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primarySwatch: Constants.kSwatchColor,
        primaryColor: Constants.kPrimary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: _loading
          ? const Center(
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
        ),
      )
          : const GinzaScreen(), getPages: getPages(),
    );
  }
}