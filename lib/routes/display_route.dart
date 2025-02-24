import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DisplayRoute extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _DisplayRouteState();
}

class _DisplayRouteState extends State<DisplayRoute> {

  int _itemCount = 0;

  late List<Map<String, dynamic>> result;

  String username = 'default';

  Future<void> getData() async {
    Database db = await openDatabase(
      '${username}_database.db',
      version: 1,
      onCreate: ((Database db, int version) async {
      await db.execute('CREATE TABLE IF NOT EXISTS Food(id INTEGER PRIMARY KEY, name TEXT, value REAL)');
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

    getData();

    return Scaffold(
      appBar: AppBar(
        title: Text('还有什么好吃的呢'),
      ),
      body: _itemCount == 0
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('还没有添加食材哦')
          ],
        ),
      )
          :
      ListView.separated(
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
      ),
    );
  }
}
