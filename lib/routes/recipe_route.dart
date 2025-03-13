import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ai_tool/global/static.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:sqflite/sqflite.dart';


class RecipeRoute extends StatefulWidget {
  const RecipeRoute({super.key});


  @override
  State<StatefulWidget> createState() => _RecipeRouteState();
}

class _RecipeRouteState extends State<RecipeRoute> with AutomaticKeepAliveClientMixin {

  Map<String, dynamic> foodMap = {};

  final client = openai.OpenAIClient(
    apiKey: Global.doubaoApiKey,
    baseUrl: Global.doubaoBaseUrl
  );



  String username = Global.username;
  late Database db;
  late List<Map<String, dynamic>> result;
  late Map<String, dynamic> consumeFood;
  List selectedIndex = [];

  String reply = ''; // ai回复
  String recipe = ''; // 食谱部分
  String consume = '';

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
    super.build(context);

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
          model: openai.ChatCompletionModel.modelId(Global.doubaoModelId),
          messages: [
            openai.ChatCompletionMessage.system(
                content: Global.dsPrompt
            ),
            openai.ChatCompletionMessage.user(
              content: openai.ChatCompletionUserMessageContent.string(text)
            ),
          ],
        ),
      );

      print('waiting...');

      await for (final res in stream) {
        setState(() {
          reply += res.choices.first.delta.content!;
          stdout.write(res.choices.first.delta.content); // 不换行输出

          List <String> replies = reply.split(RegExp(r'(<used_ingredients>|</used_ingredients>|<recipe>|</recipe>)\s*'));

          if (replies.length == 2) {
            consume = replies[1];
          }
          else if (replies.length > 3) {
            consume = replies[1];
            recipe = replies[3];
          }

          // print(replies.length);

        });
      }

      print('finish');

      consumeFood = jsonDecode(consume);

      for (var aTypeOfFood in Global.foodTypes) {
        try {
          List foodList = consumeFood[aTypeOfFood] as List;
          for (var aFood in foodList) {
            Map<String, dynamic> aFoodObject = aFood;

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
                    [(beforeNumber - number).round(), name]
                );
              }
            }
          }


        } catch(e) {
          print('$aTypeOfFood类型不存在：$e');
        }
      }

      print(reply);
      print(consume);

    } catch (e) {
      print('请求失败：$e');
    }
  }

  @override
  bool get wantKeepAlive => true;

}