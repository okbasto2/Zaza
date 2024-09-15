import 'package:image_picker/image_picker.dart';

class Message{
  String text;
  XFile? image;
  final bool isUser;

  Message({required this.isUser ,this.image, required this.text});

}