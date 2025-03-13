import 'dart:convert';
import 'dart:io';
import 'package:ai_tool/global/static.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openai_dart/openai_dart.dart' as openai;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';

class OtherOperations {

  // AI的完整回复
  Future<String> fullResponse(openai.OpenAIClient client, File? image) async {
    String reply = '';
    String base64Image = '';

    try {
      // if (text.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('请输入文本')),
      //   );
      //   return;
      // }
      if (image != null) {
        // 转换图片为 base64
        base64Image = await imageToBase64(image);
        print('base64Image: $base64Image'); // 检查转换后的 base64 是否有效
      }
      else {
        Fluttertoast.showToast(msg: '请选择图片');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('请选择图片')),
        // );
        return '';
      }

      final response = await client.createChatCompletion(
          request: openai.CreateChatCompletionRequest(
            model: openai.ChatCompletionModel.modelId(Global.doubaoModelId),
            messages: [
              openai.ChatCompletionMessage.system(
                  content: Global.doubaoPrompt
              ),
              openai.ChatCompletionMessage.user(
                  content: openai.ChatCompletionUserMessageContent.parts(
                      [
                        if (base64Image.isNotEmpty)
                          openai.ChatCompletionMessageContentPart.image(
                            imageUrl: openai.ChatCompletionMessageImageUrl(
                              url: 'data:image/jpg;base64,$base64Image',
                              detail: openai.ChatCompletionMessageImageDetail.high,
                            ),
                          ),
                      ]
                  )
              ),


            ],
            // responseFormat: openai.ResponseFormat.jsonSchema(jsonSchema: jsonSchema)
          )
      );

      // setState(() {
      //   reply = response.choices.first.message.content!;
      // });

      reply = response.choices.first.message.content!;

      print(reply);
      return reply;

    } catch (e) {
      print('请求失败：$e');
      return '';
    }
  }

  // 完整的更新食材
  Future<void> updateFood(openai.OpenAIClient client, File? image) async {
  String reply = await fullResponse(client, image); // 等ai响应

  var db = await openDatabase(
    '${Global.username}_database.db',
    version: 1,
    onCreate: ((Database db, int version) async {

      await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');
    }
    )
  );

  await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');  // 开发环境可能需要



  Map<String, dynamic> food = jsonDecode(reply); // 不是哥们，原来你把内层的也转化成对象了吗

  for (var aTypeOfFood in Global.foodTypes) {
    List foodList = food[aTypeOfFood] as List;
    for (var aFood in foodList) { // 不是哥们
      // print(j.runtimeType);
      Map<String, dynamic> aFoodObject = aFood;

      // recordAllFoodList.add(aFoodObject); // 记录所有添加的食材 // 暂时弃用

      for (var entry in aFoodObject.entries) {

        String name = entry.key;
        dynamic number = entry.value;

        List<Map<String, dynamic>> searchResult = await db.query(
          'Food',
        where: 'name = ?',
          whereArgs: [name]

        );

        if (searchResult.isNotEmpty) { // 如果先前有这条食材
          Map<String, dynamic> result = searchResult.first;
          double beforeNumber = result['value'] ?? 0;

          await db.rawUpdate( // 更新数据
          'UPDATE Food SET value = ? WHERE name = ?',
          [(beforeNumber + number).round(), name]
          );
        }
        else {
          await db.rawInsert(
              'INSERT INTO Food(name, value, type) VALUES(?, ?, ?)',
              [name, number, aTypeOfFood]

          );
        }
      }

    }

  }

  await db.close();

  print('finish');
}

  // 变成base64
  Future<String> imageToBase64(File? image) async {
    if (image == null) {
      return '';
    }

    List<int> imageBytes = image.readAsBytesSync();

    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  // 相机拍照
  Future<File?> captureImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    File? image;
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }

    return image;
  }

  // 从相册选取图片
  Future<File?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    File? image;
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }

    return image;
  }
}