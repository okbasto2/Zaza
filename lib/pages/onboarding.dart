import 'package:flutter/material.dart';
import 'package:gemini/pages/MyHomePage.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(height: 100,width: 250, child: Image.asset('assets/zaza.png', color: const Color(0xFF673AB7),)),
              const SizedBox(height: 10,),
              Image.asset('assets/onboarding2.png',),
              const SizedBox(height: 32,),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF673AB7)),
                  elevation: WidgetStatePropertyAll(15),
                ),
                onPressed: (){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (route) => false
                    );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Continue', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,color: Colors.white),),
                    SizedBox(height: 50,width: 10,),
                    Icon(Icons.arrow_forward, size: 30, color: Colors.white,)
                  ],
                )
                )
              
            ],
          ),
        ),
      ),
    );
  }
}