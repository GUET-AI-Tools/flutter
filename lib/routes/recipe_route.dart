import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ai_tool/global/static.dart';
import 'package:ai_tool/routes/recipe_detail_route.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:sqflite/sqflite.dart';


class Recipe {
  Recipe(
      this.name,
      this.content,
      this.ingredients
      );
  String name = '';
  String content = '';
  String ingredients = '';
}

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

  late String ingredients = '';

  bool _isLoading = true;

  Future<void> getData() async {
    try {

      for (var i in Global.foodTypes) {
        foodMap[i] = [];
      }

      db = await openDatabase(
          '${username}_database.db',
          version: 1,
          onCreate: ((Database db, int version) async {
            await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');
            await db.execute('CREATE TABLE IF NOT EXISTS Recipes(id INTEGER PRIMARY KEY, name TEXT, content TEXT, ingredients TEXT, createTime INTEGER)');
          })
      );

      await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS Recipes(id INTEGER PRIMARY KEY, name TEXT, content TEXT, ingredients TEXT, createTime INTEGER)');

      print('Querying');

      result = await db.rawQuery(
          'SELECT * FROM Food WHERE value > 0'
      );

      for (var i = 0; i < result.length; i++) {
        String name = result[i]['name'];
        String type = result[i]['type'];

        double number = double.parse((result[i]['value'] as double).toStringAsFixed(2)) * 100 % 100 == 0// 保留两位小数
            ? (result[i]['value'] as double).roundToDouble()
            : ((result[i]['value'] as double) * pow(10, 2)).round() / 100;

        if (!foodMap.containsKey(type)) {
          foodMap[type] = [];
        }

        (foodMap[result[i]['type']] as List).add({name : number});
      }

      ingredients = jsonEncode(foodMap);
      print('生成的JSON: $ingredients');

      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
      ingredients = '{}';

      // 处理错误
    }

    return;
  }

  Future<void> _initializeData() async {
    await getData();
    setState(() {
      _isLoading = false;
      print('initialize completed');
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );


    }


    return Scaffold(

      body: Scrollbar(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.all(16),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 2)
                            )
                          ]
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          Recipe recipe = await _streamResponse();
                          print('食谱数据：${recipe.name}\n${recipe.content}');
                          await saveRecipe(recipe);

                        },
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  buildRecipeList(),

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

  Future<void> saveRecipe(Recipe recipe) async {
    await db.insert('Recipes', {
      'name': recipe.name,
      'content': recipe.content,
      'ingredients': recipe.ingredients,
      'createTime': DateTime.now().millisecondsSinceEpoch
    });
  }

  Widget buildRecipeList() {
    print(_isLoading);
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: db.query('Recipes', orderBy: 'createTime DESC'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var recipe = snapshot.data![index];

            return InkWell(
              onTap: () => _showRecipeDetail(recipe['name'], recipe['content']),
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '创建时间: ${DateTime.fromMillisecondsSinceEpoch(recipe['createTime']).toString().substring(0, 16)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

      },
    );

  }

  void _showRecipeDetail(String name, String content) {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => RecipeDetailRoute(recipeName: name, recipeDescription: content))
    );
  }

  Future<Recipe> _streamResponse() async {
    if (db == null || !db.isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('数据库尚未初始化或已关闭')),
      );
      return Recipe('', '', '');
    }

    if (ingredients.isEmpty || ingredients == "{}") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('没有可用的食材数据')),
      );
      return Recipe('', '', '');
    }

    reply = '';
    recipe = '';
    consume = '';

    final stream = client.createChatCompletionStream(
      request: openai.CreateChatCompletionRequest(
        model: openai.ChatCompletionModel.modelId(Global.doubaoModelId),
        messages: [
          openai.ChatCompletionMessage.system(
              content: Global.dsPrompt
          ),
          openai.ChatCompletionMessage.user(
              content: openai.ChatCompletionUserMessageContent.string(ingredients)
          ),
        ],
      ),
    );

    print('ingredients: $ingredients');

    try {
      try {

        print('send message');

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

        consumeFood = jsonDecode(consume);

        for (var aTypeOfFood in Global.foodTypes) {
          if (consumeFood.containsKey(aTypeOfFood) && consumeFood[aTypeOfFood] != null) {
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
              print('处理$aTypeOfFood类型时出错：$e');
            }
          }

        }

        print(reply);
        print(consume);
        return Recipe(recipe.split('\n')[0], recipe.split('\n').sublist(1).join('\n'), consume);

      } catch (e) {
        print('请求失败：$e');
        return Recipe('', '', '');
      }
    } catch (e) {
      print('请求失败：$e');
      return Recipe('', '', '');
    }



  }



  @override
  bool get wantKeepAlive => true;

}