import 'package:hive/hive.dart';
part 'hive.g.dart';

@HiveType(typeId: 1, adapterName: "MessageAdapter")
class HiveMessage{
  @HiveField(0)
  String text;
  @HiveField(1)
  String? imagePath;
  @HiveField(2)
  bool isUser;
  HiveMessage({required this.text, this.imagePath, required this.isUser});
}