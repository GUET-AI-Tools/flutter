import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sqflite/sqflite.dart';

class DisplayRoute extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => _DisplayRouteState();
}

class _DisplayRouteState extends State<DisplayRoute> {

  int _itemCount = 0;

  late List<Map<String, dynamic>> result;

  String username = 'default';

  int? selectedIndex;

  final TextEditingController _numberController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

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
      foodGridList(),

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
        double number = result[index]['value'] is int
            ? (result[index]['value'] as int).toDouble()
            : result[index]['value'];

        return AnimationConfiguration.staggeredGrid(
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
                            _numberController.text = number.toInt().toString();
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
                                    IconButton(onPressed: () {

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

                                        ),
                                      )
                                    else
                                    Text('${number.round()}',
                                        textScaler: TextScaler.linear(1.2)
                                    ),

                                    if (selectedIndex == index)
                                    IconButton(onPressed: () {
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
}
