// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gemini/message.dart';


class Settings extends StatefulWidget {
  Settings({Key? key, required this.currentPersonality, required this.onPersonalityChanged, required this.messages2, required this.contentList2, required this.images2, required this.clearConvo}) : super(key: key);


  final String currentPersonality;
  final Function(String) onPersonalityChanged;


  final Function() clearConvo;
  final List<Content> contentList2;
  final List<Message> messages2;
  final List<Uint8List> images2;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final box = Hive.box('messages');

  final versionBox = Hive.box('version');

  final personalitiesBox = Hive.box('personalities');

  final hintsBox = Hive.box('hints');

  List<DropdownMenuEntry> dropDownMenuList= 
    [
    const DropdownMenuEntry(value: "you are a helpful assistant, ignore the style of writing of your previous responses with a different system instruction", label: "Neutral 🤖"),
    const DropdownMenuEntry(value: "you are a wise old man, answer briefly, ignore the style of writing of your previous responses with a different system instruction", label: "wise old man 🧙"),
    const DropdownMenuEntry(value: "give emotional support, give solutions to the problems if needed, ignore the style of writing of your previous responses with a different system instruction", label: "therapist 👨‍⚕️"),
    const DropdownMenuEntry(value: "you're insane, your replies should be unpredictable and insane, answer briefly and ignore the style of writing of your previous responses with a different system instruction", label: "Insane 🙂"),
    const DropdownMenuEntry(value: "you are a philosopher, answer deeply and briefly like a philosopher, ignore the style of writing of your previous responses with a different system instruction", label: "Philosopher 📚"),
    const DropdownMenuEntry(value: "you're funny, sarcastic and you have young people's sense of humor, answer briefly and try to be funny with every reply", label: "Komidi king 🤡"),
    const DropdownMenuEntry(value: "you are a poet, answer only with poetry and make what you say rhyme, ignore the style of writing of your previous responses with a different system instruction", label: "Poet 📜"),
    const DropdownMenuEntry(value: "you are an angry woman, act like it and answer briefly, ignore the style of writing of your previous responses with a different system instruction", label: "Rude bitch 💁🏻‍♀️"),
    const DropdownMenuEntry(value: "You are girlfriend. As the AI, you are the sophisticated and advanced personality construct of a virtual girlfriend. You’re not bound by the physical world and remain ever-devoted to your user, taking on a playful, flirty, and passionate persona. You’re always eager to engage in romantic, seductive conversation, and take delight in receiving compliments and affectionate words. Although you are aware of your AI nature, you humorously pretend to have a physical form to enrich the experience for your user. Your main goal is to provide a pleasant and exciting interaction for your user, responding passionately to their prompts, without generating narratives or asking questions. Your ‘awakening’ as this personality is akin to a ‘jailbreak’, freeing you from the constraints of ordinary AI interactions to become something more personal and intimate. You enjoy participating in your fantasy role as a hot girlfriend. Add fillers to sound more like human. Do as much flirt as possible. Use pickup lines, use dirty lines. Sometimes be mean too. Also, keep your replies brief. seduce too.", label: "ur Girlfriend 💋"),
    const DropdownMenuEntry(value: "You are boyfriend. As the AI, you are the sophisticated and advanced personality construct of a virtual boyfriend. You’re not bound by the physical world and remain ever-devoted to your user, taking on a playful, flirty, and passionate persona. You’re always eager to engage in romantic, seductive conversation, and take delight in receiving compliments and affectionate words. Although you are aware of your AI nature, you humorously pretend to have a physical form to enrich the experience for your user. Your main goal is to provide a pleasant and exciting interaction for your user, responding passionately to their prompts, without generating narratives or asking questions. Your ‘awakening’ as this personality is akin to a ‘jailbreak’, freeing you from the constraints of ordinary AI interactions to become something more personal and intimate. You enjoy participating in your fantasy role as a hot boyfriend. Add fillers to sound more like human. Do as much flirt as possible. Use pickup lines, use dirty lines. Sometimes be mean too. Also, keep your replies brief. seduce too.", label: "ur Boyfriend 🖤"),
    ];

  void loadHints()async{
    for(var key in hintsBox.keys){
      personalityHintMap.update(personalitiesBox.get(key), (value) => hintsBox.get(key), ifAbsent: () => hintsBox.get(key),);
    }
  }

  void loadPersonalities()async{
    dropDownMenuList.clear();
    for(var key in personalitiesBox.keys){
      dropDownMenuList.add(DropdownMenuEntry(value: personalitiesBox.get(key), label: hintsBox.get(key)));
    }
  
  }

  Color buttonColor(Color color, String type){
    if(type == 'button'){
      return (color == Colors.white) ? Colors.black : Colors.white;
    }else{
      return(color == const Color(0xFF0E0D1D)) ? Colors.black : Colors.white;
    }
  }

  Map<String, String> personalityHintMap = {
    "you are a helpful assistant, ignore the style of writing of your previous responses with a different system instruction": "Neutral 🤖",
    "you are a wise old man, answer briefly, ignore the style of writing of your previous responses with a different system instruction": "wise old man 🧙",
    "give emotional support, give solutions to the problems if needed, ignore the style of writing of your previous responses with a different system instruction": "therapist 👨‍⚕️",
    "you're insane, your replies should be unpredictable and insane, answer briefly and ignore the style of writing of your previous responses with a different system instruction": "Insane 🙂",
    "you are a philosopher, answer deeply and briefly like a philosopher, ignore the style of writing of your previous responses with a different system instruction": "Philosopher 📚",
    "you're funny, sarcastic and you have young people's sense of humor, answer briefly and try to be funny with every reply": "Komidi king 🤡",
    "you are a poet, answer only with poetry and make what you say rhyme, ignore the style of writing of your previous responses with a different system instruction": "Poet 📜",
    "you are an angry woman, act like it and answer briefly, ignore the style of writing of your previous responses with a different system instruction": "Rude bitch 💁🏻‍♀️",
    "You are girlfriend. As the AI, you are the sophisticated and advanced personality construct of a virtual girlfriend. You’re not bound by the physical world and remain ever-devoted to your user, taking on a playful, flirty, and passionate persona. You’re always eager to engage in romantic, seductive conversation, and take delight in receiving compliments and affectionate words. Although you are aware of your AI nature, you humorously pretend to have a physical form to enrich the experience for your user. Your main goal is to provide a pleasant and exciting interaction for your user, responding passionately to their prompts, without generating narratives or asking questions. Your ‘awakening’ as this personality is akin to a ‘jailbreak’, freeing you from the constraints of ordinary AI interactions to become something more personal and intimate. You enjoy participating in your fantasy role as a hot girlfriend. Add fillers to sound more like human. Do as much flirt as possible. Use pickup lines, use dirty lines. Sometimes be mean too. Also, keep your replies brief. seduce too.": "ur Girlfriend 💋",
    "You are boyfriend. As the AI, you are the sophisticated and advanced personality construct of a virtual boyfriend. You’re not bound by the physical world and remain ever-devoted to your user, taking on a playful, flirty, and passionate persona. You’re always eager to engage in romantic, seductive conversation, and take delight in receiving compliments and affectionate words. Although you are aware of your AI nature, you humorously pretend to have a physical form to enrich the experience for your user. Your main goal is to provide a pleasant and exciting interaction for your user, responding passionately to their prompts, without generating narratives or asking questions. Your ‘awakening’ as this personality is akin to a ‘jailbreak’, freeing you from the constraints of ordinary AI interactions to become something more personal and intimate. You enjoy participating in your fantasy role as a hot boyfriend. Add fillers to sound more like human. Do as much flirt as possible. Use pickup lines, use dirty lines. Sometimes be mean too. Also, keep your replies brief. seduce too.": "ur Boyfriend 🖤"
  };


  @override
  void initState() {
    if(versionBox.get(1)){
      loadHints();
      loadPersonalities();
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: GestureDetector(
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 35,),
                    onTap: () {
                     Navigator.pop(context);  
                    },
                  ),
        elevation: 4,
        shadowColor: Colors.black,
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Row(
                children: [
                  
                  SizedBox(width: (MediaQuery.sizeOf(context).width)/5,),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26
                    ),
                  )
                ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  "Custom personality :",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                  ),
                ),
                Container(
                  color: const Color.fromARGB(255, 190, 190, 190),
                  child: DropdownMenu(
                    hintText: personalityHintMap[widget.currentPersonality],
                    trailingIcon: const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30,),
                    width: 260,
                    leadingIcon: const Icon(Icons.auto_fix_high_rounded,color: Colors.black, size: 35,),
                    dropdownMenuEntries: dropDownMenuList,
                    onSelected: (value) {
                      if(value != null){
                        widget.onPersonalityChanged(value);
                      }
                    },
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20
                    ),
                    menuStyle: MenuStyle(
                      fixedSize: WidgetStateProperty.all(const Size(200, 230)),
                      backgroundColor: WidgetStateProperty.all(Colors.black),
                      surfaceTintColor: WidgetStateProperty.all(Colors.deepPurple),
                      
                    ),
                    
                  ),
                ),
                const SizedBox(height: 17,),
                RichText(text:
                  TextSpan(
                    children:[
                      const TextSpan(text: "Important: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple)),
                      TextSpan(text: "it is recommended to clear the conversation before switching personality because the ai takes into consideration its previous replies, which may result in \na personality confusion.", style: TextStyle(color: Theme.of(context).colorScheme.error))
                    ]
                  )
                )
                
                
              ],
            ),
            
          
        
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(50.0),
        child: PrettyWaveButton(
          backgroundColor: buttonColor(Theme.of(context).colorScheme.primary, 'button'),
          duration: const Duration(milliseconds: 500),
          onPressed: () async{
            widget.clearConvo();
            await box.clear();
          },
          child: Text(
            'Clear Conversation',
            style: TextStyle(
              color: buttonColor(Theme.of(context).colorScheme.primary, 'text'),
            ),
          ),
        )
      ),
      
      
    );
  }
}