import 'dart:convert';
import 'dart:io';
import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InputRoute extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _InputRouteState();
}

class _InputRouteState extends State<InputRoute> {

  String text = ''; // 你的输入文字
  String reply = ''; // ai回复

  String base64Image = ''; // base64图片
  File? _image; // 图片

  final ImagePicker _picker = ImagePicker(); // 字面意思

  // 豆包
  final client = openai.OpenAIClient(
      apiKey: '908ff8ed-3064-4be1-bec3-43dd8afe3760',
      baseUrl: 'https://ark.cn-beijing.volces.com/api/v3'
  );


  // 图片变成base64
  Future<String> imageToBase64(File? image) async {
    if (image == null) {
      return '';
    }

    List<int> imageBytes = image.readAsBytesSync();

    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  @override
  Widget build(BuildContext context) {

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
                      onPressed: _fullResponse,
                      child: Text('识别')
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
}