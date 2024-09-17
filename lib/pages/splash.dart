import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gemini/pages/MyHomePage.dart';
import 'package:gemini/pages/onboarding.dart';
import 'package:gemini/authentication/signup.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'dart:typed_data';



class SplashScreen extends StatefulWidget {
  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreen>{


  bool? newUpdate;
  var versionBox = Hive.box('version');

  Future<int> loadCurrentVersion() async{
    if (versionBox.keys.isEmpty) {
      return int.parse((await PackageInfo.fromPlatform()).version.split('.').first);
    }else{
      return versionBox.get(0);
    }
  }
  Future<int> loadLatestVersion() async{
    return int.parse(utf8.decode((await FirebaseStorage.instance.ref().child('version.txt').getData())!));
  }
  void checkNewUpdate() async{
    int latestVersion = await loadLatestVersion();
    int currentVersion = await loadCurrentVersion();
    newUpdate = (latestVersion > currentVersion);
    if(newUpdate!){
      versionBox.put(0, latestVersion);
    }
  }




  


  


  @override
  void initState() {
    super.initState();
    checkNewUpdate();
    
  }



  @override
  Widget build(BuildContext context) {
        Timer(
            const Duration(seconds: 2),
                () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) =>  MyHomePage())));


    

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.deepPurple,
        body:  Center(
          child: Image.asset('assets/splashscreen.png', ),
        )
      ),
    );
  }
}