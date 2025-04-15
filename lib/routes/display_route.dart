import 'dart:convert';
import 'dart:math';
import 'package:ai_tool/global/static.dart';
import 'package:ai_tool/routes/tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sqflite/sqflite.dart';

class DisplayRoute extends StatefulWidget {
  const DisplayRoute({super.key});


  @override
  State<StatefulWidget> createState() => _DisplayRouteState();
}

class _DisplayRouteState extends State<DisplayRoute> with AutomaticKeepAliveClientMixin {

  int _itemCount = 0;

  late List<Map<String, dynamic>> result;

  String username = Global.username;
  late String jsonFoodList;

  Map<String, dynamic> foodMap = {};

  int? selectedIndex;

  final TextEditingController _numberController = TextEditingController();

  late Database db;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }


  Future<void> getData() async {
    db = await openDatabase(
      '${username}_database.db',
      version: 1,
      onCreate: ((Database db, int version) async {
      await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL, type TEXT)');
    })
    );

    result = await db.rawQuery(
      'SELECT * FROM Food WHERE value > 0'
    );

    _itemCount = result.length;


    setState(() {

    });

    return;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 在食材更新后重新构建页面，并使InkWell失去焦点
    final bool shouldRefresh = RefreshInheritedWidget.of(context)?.shouldRefresh ?? false;
    if (shouldRefresh) {
      _refresh();
    }

    getData();

    for (var i in Global.foodTypes) {
      foodMap.addAll({i : []});
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('还有什么好吃的呢'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if (_itemCount != 0)...[ // 展开操作符...将列表中的元素都添加至children
              TextField(
                decoration: InputDecoration(
                    hintText: '搜索',
                    prefixIcon: Icon(Icons.search)
                ),
              ),
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: foodGridList()
                  )
              ),
            ],

            if (_itemCount == 0)
              Text('还没有添加食材哦'),

            
            
          ],
        ),
      )
          

      

    );
  }

  Widget foodGridList() { // 网格视图
    return AnimationLimiter(
        child: GridView.builder(

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2
      ),
      itemBuilder: (BuildContext context, int index) {

        String name = result[index]['name'];
        double number = double.parse((result[index]['value'] as double).toStringAsFixed(2)) * 100 % 100 == 0// 保留两位小数
            ? (result[index]['value'] as double).roundToDouble()
            : ((result[index]['value'] as double) * pow(10, 2)).round() / 100;

        (foodMap[result[index]['type']] as List).add({name : number});



        return AnimationConfiguration.staggeredGrid( // 加载动画
            position: index,
            columnCount: 3,
            duration: Duration(milliseconds: 350),
            child: ScaleAnimation(
                child: FadeInAnimation(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Material(
                        color: Color(0xFFC1F8FF),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(

                          onTap: () {
                            selectedIndex = index;
                            _numberController.text = double.parse((result[index]['value'] as double).toStringAsFixed(2)) * 100 % 100 == 0
                                ? number.toInt().toString()
                                : (result[index]['value'] as double).toStringAsFixed(2);
                            jsonFoodList = jsonEncode(foodMap);
                            print(jsonFoodList);
                            print('点了$index');

                          },

                          borderRadius: BorderRadius.circular(16),
                          splashColor: Color(0xFFC5D3FF),

                          child: Container(
                            // margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(

                                // border: Border.all(
                                //     color: Color(0xFFC1F8FF),
                                //     width: 2
                                // ),
                                borderRadius: BorderRadius.circular(16)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textScaler: TextScaler.linear(1.3),
                                ),

                                

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (selectedIndex == index)
                                    IconButton(onPressed: () { // -1按钮
                                      number -= 1;
                                      db.rawUpdate('UPDATE Food SET value = ? WHERE name = ?', [number, name]);
                                      setState(() { // 以特定格式（若有小数点后数据就保留两位，否则显示整数）显示数值
                                        _numberController.text = double.parse((result[index]['value'] as double).toStringAsFixed(2)) * 100 % 100 == 0
                                            ? number.toInt().toString()
                                            : number.toStringAsFixed(2);
                                      });

                                    },
                                        icon: Icon(CupertinoIcons.minus_circle)
                                    ),

                                    if (selectedIndex == index)
                                      SizedBox(
                                        width: 25,
                                        height: 35,
                                        child: TextField(
                                          controller: _numberController,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(5),
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')) //输入限制
                                          ],
                                          
                                          onChanged: (v) {
                                            number = double.parse(v);
                                            db.rawUpdate('UPDATE Food SET value = ? WHERE name = ?', [number, name]);
                                          },

                                        ),
                                      )
                                    else
                                    Text(double.parse((result[index]['value'] as double).toStringAsFixed(2)) * 100 % 100 == 0
                                        ? number.toInt().toString()
                                        : (result[index]['value'] as double).toStringAsFixed(2),
                                        textScaler: TextScaler.linear(1.2)
                                    ),

                                    if (selectedIndex == index)
                                    IconButton(onPressed: () { // +1按钮
                                      number += 1;
                                      db.rawUpdate('UPDATE Food SET value = ? WHERE name = ?', [number, name]);
                                      setState(() {
                                        _numberController.text = double.parse((result[index]['value'] as double).toStringAsFixed(2)) * 100 % 100 == 0
                                            ? number.toInt().toString()
                                            : number.toStringAsFixed(2);
                                      });

                                    }, 
                                        icon: Icon(CupertinoIcons.plus_circle)
                                    )

                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                )
            )
        );
      },

      itemCount: _itemCount,
    )
    );
  }

  Widget foodList() { // 列表视图

    return ListView.separated(
      itemCount: _itemCount,

      itemBuilder: (BuildContext context, int index)  {

        String name = result[index]['name'];
        double number = result[index]['value'] is int
            ? (result[index]['value'] as int).toDouble()
            : result[index]['value'];

        // result[index].forEach((n, value) {
        //   name = n;
        //   number = value;
        // });

        return ListTile(title: Text('$name: ${number.round()}'),);
      },

      separatorBuilder: ((BuildContext context, int index) {
        return Divider(
          color: Colors.grey,
        );
      }),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      selectedIndex = null;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
