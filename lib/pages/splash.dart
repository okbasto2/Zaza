import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gemini/pages/MyHomePage.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SplashScreen extends StatefulWidget {
  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreen> {

  late Map<String, dynamic> json;
  bool? newUpdate;
  var versionBox = Hive.box('version');
  var personalitiesBox = Hive.box('personalities');
  var hintsBox = Hive.box('hints');


  Future<void> loadJson() async{
    
     json = jsonDecode(utf8.decode((await FirebaseStorage.instance.ref().child('personality.json').getData())!)) as Map<String, dynamic>;
  }

  void installHints()async{
    await hintsBox.clear();
    for(var hint in json['hints']!){
      hintsBox.add(hint);
    }
  }

  
  void installPersonalities()async{
    await personalitiesBox.clear();
    for(var personality in json['personalities']!){
      personalitiesBox.add(personality);
    }
  }

  Future<int> loadCurrentVersion() async {
    if (versionBox.get(0) == null) {
      return int.parse((await PackageInfo.fromPlatform()).version.split('.').first);
    } else {
      return versionBox.get(0);
    }
  }

  Future<int> loadLatestVersion() async {
    try {
      final versionData = await FirebaseStorage.instance.ref().child('version.txt').getData();
      return int.parse(utf8.decode(versionData!));
    } catch (e) {
      // Handle any errors during fetch
      print('Error fetching latest version: $e');
      return 0; // Default to 0 if there's an error
    }
  }

  Future<void> checkNewUpdate() async {
    try {
      int latestVersion = await loadLatestVersion();
      int currentVersion = await loadCurrentVersion();
      setState(() {
        newUpdate = (latestVersion > currentVersion);
      });
      versionBox.put(1, newUpdate);
      if (newUpdate!) {
        await loadJson();
        installHints();
        installPersonalities();
        versionBox.put(0, latestVersion);
        // Simulate downloading update (or handle actual download here)
        await Future.delayed(const Duration(seconds: 2)); // Simulate a delay
      }


    } catch (e) {
      // Handle any errors during version check
      print('Error checking for new update: $e');


    } finally {

      // Navigate to the next screen after checking for updates
      Timer(
        const Duration(seconds: 10),
        () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => const MyHomePage()),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkNewUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/splashscreen.png'),
                  if (newUpdate != null && (newUpdate!)) ...[
                    const SizedBox(height: 50),
                    const Text(
                      'New update detected!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Downloading update...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(), // Loading indicator
                  ],
                ],
              )
      ),
    );
  }
}
