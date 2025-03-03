import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ai_tool/global/static.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:sqflite/sqflite.dart';

class RecipeRoute extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _RecipeRouteState();
}

class _RecipeRouteState extends State<RecipeRoute> {

  Map<String, dynamic> foodMap = {};

  final client = openai.OpenAIClient(
    apiKey: Global.dsApiKey,
    baseUrl: Global.dsBaseUrl
  );

  String username = 'default';
  late Database db;
  late List<Map<String, dynamic>> result;
  List selectedIndex = [];

  String reply = ''; // ai回复
  String recipe = ''; // 食谱部分

  late String text = '';

  Future<void> getData() async {
    db = await openDatabase(
        '${username}_database.db',
        version: 1,
        onCreate: ((Database db, int version) async {
          await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL)');
        })
    );



    result = await db.rawQuery(
        'SELECT * FROM Food WHERE value > 0'
    );

    for (var i = 0; i < result.length; i++) {
      String name = result[i]['name'];
      double number = double.parse((result[i]['value'] as double).toStringAsFixed(2)) * 100 % 100 == 0// 保留两位小数
          ? (result[i]['value'] as double).roundToDouble()
          : ((result[i]['value'] as double) * pow(10, 2)).round() / 100;

      (foodMap[result[i]['type']] as List).add({name : number});
    }

    text = jsonEncode(foodMap);
    // print(text);

    return;
  }

  @override
  Widget build(BuildContext context) {

    for (var i in Global.foodTypes) {
      foodMap.addAll({i : []});
    }

    getData();

    return Scaffold(

      body: Scrollbar(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  ElevatedButton(onPressed: () {
                    _streamResponse();
                  },
                      child: Text('获得食谱')
                  ),

                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    child: MarkdownBlock(data: recipe),
                  ),

                ],
              ),
            ),
          )
      ),
    );
  }

  Future<void> _streamResponse() async {
    try {
      // if (text.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('请输入文本')),
      //   );
      //   return;
      // }

      print('send message');

      final stream = client.createChatCompletionStream(
        request: openai.CreateChatCompletionRequest(
          model: openai.ChatCompletionModel.modelId(Global.dsModelId),
          messages: [
            openai.ChatCompletionMessage.system(
                content: Global.dsPrompt
            ),
            openai.ChatCompletionMessage.user(
              content: openai.ChatCompletionUserMessageContentString(text)
            ),
          ],
        ),
      );

      print('waiting...');

      await for (final res in stream) {
        setState(() {
          reply += res.choices.first.delta.content!;
          stdout.write(res.choices.first.delta.content); // 不换行输出

          List <String> replies = reply.split('-----');

          if (replies.length == 1) {

          }
          else {
            recipe = replies[1];
          }

        });
      }

      print('finish');

      print(reply);

    } catch (e) {
      print('请求失败：$e');
    }
  }

}