import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gemini/pages/MyHomePage.dart';
import 'package:gemini/pages/onboarding.dart';
import 'package:gemini/authentication/signup.dart';

class SplashScreen extends StatefulWidget {
  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreen>  {

  @override
  void initState() {
    super.initState();

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