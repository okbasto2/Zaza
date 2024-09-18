import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini/pages/MyHomePage.dart';
import 'package:gemini/firebase_options.dart';
import 'package:gemini/pages/splash.dart';
import 'package:gemini/themeNotifier.dart';
import 'package:gemini/themes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:core';

import 'package:hive/hive.dart';
import 'package:gemini/hive.dart';
import 'package:hive_flutter/adapters.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();


  //initialize hive
  await Hive.initFlutter();


  //register the adapter
  Hive.registerAdapter(MessageAdapter());


  //open the box
  var messagesBox = await Hive.openBox('messages');
  var versionBox = await Hive.openBox('version');
  var personalitiesBox = await Hive.openBox('personalities');
  var hintsBox = await Hive.openBox('hints');

  //put the current version in the version box


  //initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  //loading the api key
  await dotenv.load(fileName: 'env');


  //var apikey = const String.fromEnvironment("API_KEY");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zaza',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      home: SplashScreen(),
    );
  }
}


