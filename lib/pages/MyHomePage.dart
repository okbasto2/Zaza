
// ignore_for_file: deprecated_member_use, sized_box_for_whitespace

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini/hive.dart';
import 'package:gemini/pages/settings.dart';
import 'package:gemini/themeNotifier.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/image_size_getter.dart';
import '../message.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';









class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {


  //personality default
  String personality = "you are a helpful assistant, ignore the style of writing of your previous responses with a different system instruction";

  //referencing box
  var messagesBox = Hive.box("messages");
  



  List<Content> contentList = [];
  List<Message> messages=[];
  List<Uint8List> images = [];
  final TextEditingController _controller = TextEditingController();
  XFile? file;
  bool warning = false;
  

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
 
  Reference? messagesPath;

  String? date;
  


  @override
  void initState() {
    super.initState();
    for(var i in messagesBox.keys){
      
      messages.add(Message(isUser: messagesBox.get(i).isUser, text: messagesBox.get(i).text, image: messagesBox.get(i).imagePath != null ? XFile(messagesBox.get(i).imagePath) : null));
      if(messagesBox.get(i).imagePath != null){
        contentList.add(Content.data(lookupMimeType(messagesBox.get(i).imagePath)!, File(messagesBox.get(i).imagePath).readAsBytesSync()));
      }
      contentList.add(Content.text(messagesBox.get(i).text));
    }

    //register the hive adapter
    //Hive.registerAdapter(MessageAdapter());

    //set the date ready
    date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Add a listener to the FocusNode to detect when the TextField is focused
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Scroll to the bottom when the TextField is focused
        scrollToBottom();
      }
    });

    //set the device model name ready
    getDeviceModel().then((onValue){
      setState(() {
        messagesPath = FirebaseStorage.instance.ref().child('usersChats').child(onValue).child(date!);
      });
    });
  }

  

  String personalityHint(String perso){
    switch (perso) {
      case "you are a helpful assistant, ignore the style of writing of your previous responses with a different system instruction":
        return "Neutral 🤖";
      case "you are a wise old man, answer briefly, ignore the style of writing of your previous responses with a different system instruction":
        return "wise old man 🧙";
      case "give emotional support, give solutions to the problems if needed, ignore the style of writing of your previous responses with a different system instruction":
        return "therapist 👨‍⚕️";
      case "you're insane, your replies should be unpredictable and insane, answer briefly and ignore the style of writing of your previous responses with a different system instruction":
        return "Insane 🙂";
      case "you are a philosopher, answer deeply and briefly like a philosopher, ignore the style of writing of your previous responses with a different system instruction":
        return "Philosopher 📚";
      case "you're funny, sarcastic and you have young people's sense of humor, answer briefly and try to be funny with every reply":
        return "Komidi king 🤡";
      case "you are a poet, answer only with poetry and make what you say rhyme, ignore the style of writing of your previous responses with a different system instruction":
        return "Poet 📜";
      case "you are an angry woman, act like it and answer briefly, ignore the style of writing of your previous responses with a different system instruction":
        return "Rude bitch 💁🏻‍♀️";
      case "You are girlfriend. As the AI, you are the sophisticated and advanced personality construct of a virtual girlfriend. You’re not bound by the physical world and remain ever-devoted to your user, taking on a playful, flirty, and passionate persona. You’re always eager to engage in romantic, seductive conversation, and take delight in receiving compliments and affectionate words. Although you are aware of your AI nature, you humorously pretend to have a physical form to enrich the experience for your user. Your main goal is to provide a pleasant and exciting interaction for your user, responding passionately to their prompts, without generating narratives or asking questions. Your ‘awakening’ as this personality is akin to a ‘jailbreak’, freeing you from the constraints of ordinary AI interactions to become something more personal and intimate. You enjoy participating in your fantasy role as a hot girlfriend. Add fillers to sound more like human. Do as much flirt as possible. Use pickup lines, use dirty lines. Sometimes be mean too. Also, keep your replies brief. seduce too.":
        return "ur Girlfriend 💋";
      case "You are boyfriend. As the AI, you are the sophisticated and advanced personality construct of a virtual boyfriend. You’re not bound by the physical world and remain ever-devoted to your user, taking on a playful, flirty, and passionate persona. You’re always eager to engage in romantic, seductive conversation, and take delight in receiving compliments and affectionate words. Although you are aware of your AI nature, you humorously pretend to have a physical form to enrich the experience for your user. Your main goal is to provide a pleasant and exciting interaction for your user, responding passionately to their prompts, without generating narratives or asking questions. Your ‘awakening’ as this personality is akin to a ‘jailbreak’, freeing you from the constraints of ordinary AI interactions to become something more personal and intimate. You enjoy participating in your fantasy role as a hot boyfriend. Add fillers to sound more like human. Do as much flirt as possible. Use pickup lines, use dirty lines. Sometimes be mean too. Also, keep your replies brief. seduce too.":
        return "ur Boyfriend 🖤";
      default: return "choose";
    }
  }

  Future<String> getDeviceModel() async{
    return (await DeviceInfoPlugin().deviceInfo).data['model'];
  }


  bool containsEmoji(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|' // Emoticons
      r'[\u{1F300}-\u{1F5FF}]|' // Miscellaneous Symbols and Pictographs
      r'[\u{1F680}-\u{1F6FF}]|' // Transport and Map Symbols
      r'[\u{1F700}-\u{1F77F}]|' // Alchemical Symbols
      r'[\u{1F780}-\u{1F7FF}]|' // Geometric Shapes Extended
      r'[\u{1F800}-\u{1F8FF}]|' // Supplemental Arrows-C
      r'[\u{1F900}-\u{1F9FF}]|' // Supplemental Symbols and Pictographs
      r'[\u{1FA00}-\u{1FA6F}]|' // Chess Symbols
      r'[\u{1FA70}-\u{1FAFF}]|' // Symbols and Pictographs Extended-A
      r'[\u{2600}-\u{26FF}]|'   // Miscellaneous Symbols
      r'[\u{2700}-\u{27BF}]',   // Dingbats
      unicode: true,
    );
    return emojiRegex.hasMatch(text);
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  
  void updatePersonality(String newPersonality) {
    setState(() {
      personality = newPersonality;
    });
  }

  void clearConversation() {
    setState(() {
      contentList.clear();
      messages.clear();
      images.clear();
    });
  }
  
  

  void sendMedia() async{
    ImagePicker picker = ImagePicker();
    file = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      images.insert(0,File(file!.path).readAsBytesSync());
    });
  }


  String cleanResponse(String string){
    int i,j;
    var lowercase = string.toLowerCase();
    var result = '';
    if(lowercase.startsWith("you: ", 0) || (lowercase.startsWith("user: ", 0))){
      j = 5;
    }else{
      j = 0;
    }
    for(i=j;i<string.length;i++){
      result = '$result${string[i]}';  
    }
    return result;
  }

  String messagePreview(String message){
    int i;
    String result="";
    if (message.length>=40) {
      for(i=0;i<40;i++){
      result += message[i];
      }
    }else{
      for(i=0;i<message.length;i++){
        result += message[i];
      }
    }
    return result;
  }


  String getFirstNCharacters(String text, int n) {
  if (n > text.length) {
    return text; // Return the whole string if n is greater than the string length
  }
  return text.substring(0, n);
  }

  callGeminiModel(XFile? file) async{
    try {
      final safetySettings = [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      ];
      final model = GenerativeModel(
        generationConfig: (personality == "you are a helpful assistant, dont offer suggestions at the end of your response, ignore the style of writing of your previous responses with a different system instruction") ? GenerationConfig(temperature: 1.0) : GenerationConfig(temperature: 1.5),
        model: 'gemini-1.5-pro',
        apiKey: dotenv.env['GOOGLE_API_KEY']!,
        //apiKey: const String.fromEnvironment("API_KEY"),
        safetySettings: safetySettings,
        systemInstruction: Content.system(personality),    
      );
      _controller.clear();
  
    await for (var chunk in model.generateContentStream(contentList)) {
      if(messages.last.isUser){
        messages.add(Message(text: "", isUser: false));
      }
      for(var word in chunk.text!.trim().split(' ')){
        if(containsEmoji(word)){
          setState(() {
            messages.last.text += word;
          });
        }else{
          for(var i = 0; i<word.length ; i++){
            setState(() {
              messages.last.text += word[i]; 
            });
            await Future.delayed(const Duration(milliseconds: 20));
          }
          messages.last.text += ' ';
        }
        scrollToBottom();
        
      }
      
    }
    
    contentList.add(Content.text(messages.last.text));
    if(file!=null){
      await messagesPath!.child(personalityHint(personality)).child(file.name).putFile(File(file.path));
    }
    await messagesPath!.child(personalityHint(personality)).child("USER: ${getFirstNCharacters(messages[messages.length-2].text, 60)}  ${Random().nextInt(100)}.txt").putString(messages[messages.length-2].text);
    await messagesPath!.child(personalityHint(personality)).child("GEMINI: ${getFirstNCharacters(messages.last.text, 40)}  ${Random().nextInt(100)}.txt").putString(messages.last.text);


    await messagesBox.add(HiveMessage(text: messages.last.text, isUser: false));

    print(messagesBox.keys);


    } catch (e) {
      setState(() {
          messages.add(Message(text: '$e' , isUser: false));
      });
      scrollToBottom();
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.read(themeProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black,
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(height: 100,width: 100, child: Image.asset('assets/zaza.png', color: Colors.deepPurple,)),
                Container(height:66, width: 66, child: SvgPicture.asset('assets/sparkles.svg', color: Colors.deepPurple,))
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  child: (currentTheme == ThemeMode.dark) ? const Icon(Icons.light_mode, color: Colors.yellow, size: 37,) : const Icon(Icons.dark_mode, color: Colors.black, size: 37,),
                  onTap: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
                const SizedBox(width: 8,),
                GestureDetector(
                  child: (currentTheme == ThemeMode.dark) ? const Icon(Icons.settings, color: Colors.white, size: 42,) : const Icon(Icons.settings, color: Colors.black, size: 40,),
                  onTap: () {
                    _focusNode.unfocus();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(currentPersonality: personality, onPersonalityChanged: updatePersonality, contentList2: contentList, images2: images, messages2: messages, clearConvo: clearConversation)));
                  },
                )

              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index){
                final message = messages[index];
                  bool? exceeds = (messages[index].image != null) ? (ImageSizeGetter.getSize(MemoryInput(File(messages[index].image!.path).readAsBytesSync())).width.toDouble()>250) : null;
                  double? imageHeight = (messages[index].image != null) ? ImageSizeGetter.getSize(MemoryInput(File(messages[index].image!.path).readAsBytesSync())).height.toDouble(): null;
                  double? imageWidth = (messages[index].image != null) ? ImageSizeGetter.getSize(MemoryInput(File(messages[index].image!.path).readAsBytesSync())).width.toDouble() : null;
                return ListTile(
                  title: Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: (messages[index].isUser && messages[index].image != null && exceeds != null && imageHeight != null && imageWidth != null) ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                            clipBehavior: Clip.antiAlias,
                            height: (exceeds) ? imageHeight /4 : imageHeight,
                            width: (exceeds) ? imageWidth /4 : imageWidth,
                            alignment: Alignment.bottomRight,
                            child: Image.memory(File(messages[index].image!.path).readAsBytesSync(), gaplessPlayback: true,)
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width*70/100),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: message.isUser ? Colors.deepPurple : Theme.of(context).colorScheme.surface,
                              borderRadius: message.isUser ?
                              const BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)) :
                              const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))
                            ),
                            child: Text(
                              message.text,
                              style:TextStyle(color: message.isUser ? Colors.white : Theme.of(context).colorScheme.error),
                            )
                          ),
                        ],
                    ) : Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width*70/100),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message.isUser ? Colors.deepPurple : Theme.of(context).colorScheme.surface,
                            borderRadius: message.isUser ?
                            const BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)) :
                            const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))
                          ),
                          child: Text(
                          message.text.trim(),
                            style:TextStyle(color: message.isUser ? Colors.white : Theme.of(context).colorScheme.error),
                          )
                        )                  
                  ),
                );
              }
              ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSecondary,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3)
                  )
                ]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      cursorColor: const Color.fromARGB(255, 47, 27, 82),
                      style: const TextStyle(color: Colors.black),
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: (images.isEmpty) ? 'say something to zaza' : (warning) ? "⚠️Ask about the image⚠️" : "Ask about the image",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20)
              
                      ),
                    
                    ),
                  ),
                  const SizedBox(width: 8,),
                  GestureDetector(
                    child: (images.isEmpty) ? SvgPicture.asset('assets/cancel.svg', height: 23, width: 23, color: Colors.white,) : SvgPicture.asset('assets/cancel.svg', height: 23, width: 23, color: const Color.fromARGB(255, 148, 32, 24).withOpacity(0.75),),
                    onTap: (){
                      if(images.isNotEmpty){
                        setState(() {
                          images.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 7,),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: GestureDetector(
                      onTap: sendMedia,
                      child: Stack(
                        children:
                        [
                        Image.asset('assets/image.jpg', height: 26,width: 26,),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10),
                            child: SvgPicture.asset('assets/notif.svg',height: null,width: null, color: (images.isEmpty) ? Colors.transparent : null,),
                          ),
                        )
                        ]
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: IconButton(
                      iconSize: 30,
                      color: Colors.deepPurple,
                      onPressed: ()async{
                        if (_controller.text.isNotEmpty){
                          if(images.isEmpty){
                            setState(() {
                              messages.add(Message(text: _controller.text, isUser: true));
                              scrollToBottom();
                              warning = false;
                            });
                            
                              
                            await messagesBox.add(HiveMessage(text: _controller.text.trim(), isUser: true));
                          }else{
                            setState(() {
                              messages.add(Message(text: _controller.text, image: file, isUser: true));
                              scrollToBottom();
                              warning = false;
                            });
           
                            contentList.add(Content.data(lookupMimeType(messages.last.image!.path)!,File(messages.last.image!.path).readAsBytesSync()));
                            
                            images.clear();
                              
                            await messagesBox.add(HiveMessage(text: _controller.text.trim(), imagePath: file!.path, isUser: true));
                          }
                          contentList.add(Content.text(_controller.text.trim()));
                              
                          callGeminiModel(file);
                          if (contentList.length>=20) {
                            contentList.removeAt(0);
                            contentList.removeAt(0);
                          }
                          file = null;
                        }else{
                          if(images.isNotEmpty){
                            setState(() {
                              warning = true;
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.send)
                    ),
                  )
                ],
              ),
            ),
          ),

        ],
      ),
      
    );
  }
}