import 'dart:convert';
import 'dart:io';
import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class InputRoute extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _InputRouteState();
}

class _InputRouteState extends State<InputRoute> {

  String text = ''; // 你的输入文字
  String reply = ''; // ai回复

  String base64Image = ''; // base64图片
  File? _image; // 图片

  String username = 'default';


  List<String> foodTypes = ['谷物', '蔬菜', '水果', '豆类', '坚果', '肉类', '蛋类', '乳制品', '油脂', '糖类', '罐头'];

  List recordAllFoodList = []; // 处理完后的所有所有食物以及它们的数量

  final ImagePicker _picker = ImagePicker(); // 字面意思

  // 豆包
  final client = openai.OpenAIClient(
      apiKey: '908ff8ed-3064-4be1-bec3-43dd8afe3760',
      baseUrl: 'https://ark.cn-beijing.volces.com/api/v3'
  );

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync(); // SharedPreferences

  // Future<void> startDatabase(String username) async {
  //   var db = await openDatabase('${username}_database');
  // }

  // 图片变成base64
  Future<String> imageToBase64(File? image) async {
    if (image == null) {
      return '';
    }

    List<int> imageBytes = image.readAsBytesSync();

    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }
  // 从相册选取图片
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 相机拍照
  Future<void> _captureImageFromCamera() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('食材我来辣'),
      ),

      body: Scrollbar(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      ElevatedButton(onPressed: () {
                        _captureImageFromCamera();
                      },
                          child: Text('拍照')
                      ),

                      ElevatedButton(onPressed: () {
                        _pickImageFromGallery();
                      },
                          child: Text('选择图片')
                      ),

                    ],
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await _fullResponse(); // 等ai响应

                        var db = await openDatabase(
                            '${username}_database.db',
                            version: 1,
                            onCreate: ((Database db, int version) async {

                              await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');
                            }
                            )
                        );

                        await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');  // 开发环境可能需要



                        Map<String, dynamic> food = jsonDecode(reply); // 不是哥们，原来你把内层的也转化成对象了吗

                        for (var aTypeOfFood in foodTypes) {
                          List foodList = food[aTypeOfFood] as List;
                          for (var aFood in foodList) { // 不是哥们
                            // print(j.runtimeType);
                            Map<String, dynamic> aFoodObject = aFood;

                            recordAllFoodList.add(aFoodObject); // 记录所有添加的食材

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
                      },
                      child: Text('识别')
                  ),
                  ElevatedButton(
                      onPressed: _deleteAll, 
                      child: Text('删除所有食材（调试功能）')
                  )

                ],
              ),
            ),
          )
      )
    );
  }

  Future<void> _fullResponse() async {
    try {
      // if (text.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('请输入文本')),
      //   );
      //   return;
      // }
      if (_image != null) {
        // 转换图片为 base64
        base64Image = await imageToBase64(_image);
        print('base64Image: $base64Image'); // 检查转换后的 base64 是否有效
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请选择图片')),
        );
        return;
      }

      final response = await client.createChatCompletion(
          request: openai.CreateChatCompletionRequest(
            model: openai.ChatCompletionModel.modelId('ep-20250219134730-wbfm4'),
            messages: [
              openai.ChatCompletionMessage.system(
                  content: '你需要将输入的图片中的食材以json格式输出，不需要附带其他内容，需要在json中列出物品的名字与数量并按 谷物、蔬菜、水果、豆类、坚果、肉类、蛋类、乳制品、油脂、糖类、罐头 进行分类。每个分类对应一个数组，数组中存放对应的所有食材的名字与数量，食材与数量应当以键值对的形式输出，若分类中不存在对应的食材也要输出对应的数组。忽略物品的颜色与大小，名字仅输出其常用名称，数量不需要量词。'
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

      setState(() {
        reply = response.choices.first.message.content!;
      });

      print(reply);

    } catch (e) {
      print('请求失败：$e');
    }
  }

  Future<void> _deleteAll() async { // 清空数据
    var db = await openDatabase(
        '${username}_database.db',
        version: 1,
        onCreate: ((Database db, int version) async {
          await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');
        }
        )
    );

    await db.execute('DROP TABLE IF EXISTS Food');

    await db.close();

    print('删完了');
    return;
  }
}